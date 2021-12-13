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
    dates = ((Date.today - 1.week)..date).to_a.reverse
    if date.yday < et_product.default_doy_start || date.yday >= et_product.default_doy_end
      Rails.logger.info "ET mailer not sent, currently outside of date range."
      return "Product inactive" unless Rails.env.development?
    end
    Subscriber.all.each do |subscriber|
      subs = subscriber.subscriptions.where(product: et_product).map do |sub|
        # collect ets for location
        vals = dates.map do |date|
          AgWeather.get_et_value(date, sub.latitude, sub.longitude)
        end

        # cumulative sum of ets
        sum = 0
        cum_vals = vals.map do |v|
          sum += v.negative? ? 0 : v
        end

        # return data
        {
          site_name: sub.name,
          latitude: sub.latitude,
          longitude: sub.longitude,
          dates: dates,
          values: vals,
          cum_vals: cum_vals
        }
      end
      # end.select { |val| val[:value] > 0 }
      SubscriptionMailer.daily_mail(subscriber, date, subs).deliver if subs.length > 0
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
