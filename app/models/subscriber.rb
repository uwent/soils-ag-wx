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

  def self.send_daily_mail
    Rails.logger.info "Subscriber :: Sending daily mail..."

    if Date.current == Subscription.dates_active.first
      Rails.logger.info "Subscriber :: Enabling all subscriptions at start of season"
      Subscription.enable_all
    end

    if Date.current == Subscription.dates_active.last + 1.day
      Rails.logger.info "Subscriber :: Disabling all subscriptions at end of season"
      Subscription.disable_all
    end

    if Subscription.enabled.size > 0
      send_subscriptions(Subscriber.all)
    else
      Rails.logger.info "Subscriber :: No subscriptions to send!"
    end
  end

  def self.send_subscriptions(subscribers)
    date = Date.yesterday
    dates = (date - 6.days)..date

    # collect data
    subscriptions = Subscription.where(subscriber: subscribers)

    if subscriptions.size > 0
      sites = subscriptions.pluck(:latitude, :longitude).uniq

      all_data = {}
      sites.each do |site|
        lat, long = site

        opts = {
          lat: lat,
          long: long,
          start_date: dates.first,
          end_date: dates.last
        }

        ets = AgWeather.get(AgWeather::ET_URL, query: opts)[:data]
        precips = AgWeather.get(AgWeather::PRECIP_URL, query: opts.merge({units: "in"}))[:data]
        weathers = AgWeather.get(AgWeather::WEATHER_URL, query: opts.merge({units: "F"}))[:data]

        # collect and format data for each date
        site_data = {}
        dates.each do |date|
          datestring = date.to_formatted_s
          weather = weathers.find { |h| h[:date] == datestring }
          precip = precips.find { |h| h[:date] == datestring }
          et = ets.find { |h| h[:date] == datestring }
          site_data[datestring] = {
            date: date.strftime("%a, %b %-d"),
            min_temp: weather.nil? ? "No data" : sprintf("%.1f", weather[:min_temp]),
            max_temp: weather.nil? ? "No data" : sprintf("%.1f", weather[:max_temp]),
            precip: precip.nil? ? "No data" : sprintf("%.2f", precip[:value]),
            et: et.nil? ? "No data": sprintf("%.3f", et[:value])
          }
        end

        # add site's weekly data to main hash
        all_data[[lat, long].to_s] = site_data
      end

      Subscriber.all.each do |subscriber|
        subscriptions = subscriber.subscriptions.order(:name)
        data = subscriptions.collect do |subscription|
          lat = subscription.latitude
          long = subscription.longitude
          site_key = [lat, long].to_s
          {
            site_name: subscription.name,
            lat: lat,
            long: long,
            site_data: all_data[site_key]
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
