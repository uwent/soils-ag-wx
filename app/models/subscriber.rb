class Subscriber < ApplicationRecord
  has_many :subscriptions

  # per http://stackoverflow.com/questions/201323/using-a-regular-expression-to-validate-an-email-address
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create}

  before_create :set_confirmation_token

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

  def is_confirmed?
    !confirmed_at.nil?
  end

  def confirm!(token)
    if token == confirmation_token
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
    validation_code == validation_token
  end

  def self.send_daily_mail
    Rails.logger.info "Subscriber :: Sending daily mail for #{date.to_s}..."
    Subscription.enable_all if Date.current == Subscription.dates_active.first
    
    if Subscription.enabled.size > 0
      send_subscriptions(Subscriber.all)
    else
      Rails.logger.info "Subscriber :: No active subscriptions to send for #{date.to_s}"
    end

    Subscription.disable_all if Date.current == Subscription.dates_active.last
  end

  def self.fetch_weather(sites, dates)
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
      Rails.logger.debug "Ets: #{ets}"
      Rails.logger.debug "Precips: #{precips}"
      Rails.logger.debug "Weather: #{weathers}"

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

      Rails.logger.debug "Site data: #{site_data}"

      # add site's weekly data to main hash
      all_data[[lat, long].to_s] = site_data
    end
    all_data
  end

  def self.send_subscriptions(subscribers)
    date = Date.yesterday
    dates = (date - 6.days)..date

    # collect data
    all_subs = Subscription.where(subscriber: subscribers, enabled: true)

    if all_subs.size > 0
      sites = all_subs.pluck(:latitude, :longitude).uniq
      Rails.logger.debug "Sites: #{sites}"
      weather_data = fetch_weather(sites, dates)

      # send emails to each subscriber with their sites
      subscribers.each do |subscriber|
        subscriptions = subscriber.subscriptions.enabled.order(:name)

        if subscriptions.size > 0
          data = subscriptions.collect do |subscription|
            lat = subscription.latitude
            long = subscription.longitude
            site_key = [lat, long].to_s
            {
              site_name: subscription.name,
              lat: lat,
              long: long,
              site_data: weather_data[site_key]
            }
          end
          SubscriptionMailer.daily_mail(subscriber, date, data).deliver
        end
      end
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[ID Name Email Created Admin]
      Subscriber.all.order(:id).each do |s|
        csv << [s.id, s.name, s.email, s.created_at, s.admin]
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
