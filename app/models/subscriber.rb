class Subscriber < ApplicationRecord
  before_create :set_confirmation_token
  has_many :subscriptions
  has_many :products, through: :subscriptions
  # per http://stackoverflow.com/questions/201323/using-a-regular-expression-to-validate-an-email-address
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create}

  def self.fractional_part(float)
    float.to_s =~ /0\.(.+)$/
    $1
  end

  def self.confirmation_number
    fractional_part(rand)
  end

  def self.email_find(email)
    where("lower(email) = ?", email.downcase).first
  end

  def send_subscriptions(start_date = Date.today - 1, finish_date = Date.today - 1)
  end

  def is_confirmed?
    !confirmed_at.nil?
  end

  def confirm!(token)
    if confirmation_token == token
      self.confirmed_at = Time.current
      save!
      true
    else
      false
    end
  end

  def generate_validation_token
    self.validation_token = random_code[0..5]
    self.validation_created_at = Time.current
    save!
    SubscriptionMailer.validation(self).deliver
  end

  def is_validation_token_old?
    validation_created_at + 1.hour <= Time.current
  end

  def validation_token_valid?(validation_code)
    validation_token == validation_code
  end

  def self.send_daily_mail(date = Date.current - 1.day)
    et_product = Product.where(name: "Evapotranspiration").first
    dates = (date - 6.days)..date
    if date.yday < et_product.default_doy_start || date.yday >= et_product.default_doy_end
      Rails.logger.info "ET mailer not sent, currently outside of date range."
      return "Product inactive" unless Rails.env.development?
    end

    # TODO: this should be made much more efficient. Collect all subscribed locations then query AgWeather for the date range for each location.

    Subscriber.all.each do |subscriber|
      subs = subscriber.subscriptions.where(product: et_product)
      puts subs

      if subs.size > 0
        data = subs.map do |site|
          # collect ets for location
          ets = AgWeather.get_et_values(site.latitude, site.longitude, date, dates.first)

          # convert to hash
          vals = {}
          ets.each do |val|
            vals[val[:date]] = val[:value]
          end

          # match received ETs to date list
          vals = dates.collect do |day|
            key = day.to_formatted_s
            vals[key].nil? ? -1 : vals[key]
          end

          # cumulative sum of ets
          sum = 0
          cum_vals = vals.map do |val|
            sum += val.negative? ? 0 : val
          end

          {
            site_name: site.name,
            latitude: site.latitude,
            longitude: site.longitude,
            dates: dates,
            values: vals,
            cum_vals: cum_vals
          }
        end
        SubscriptionMailer.daily_mail(subscriber, date, data).deliver
      end
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      Subscriber.all.order(:email).each do |subscriber|
        csv << [subscriber.email]
      end
    end
  end

  private

  def set_confirmation_token
    self.confirmation_token = random_code
  end

  def random_code
    f = rand
    f.to_s =~ /0\.(.+)$/
    $1
  end
end
