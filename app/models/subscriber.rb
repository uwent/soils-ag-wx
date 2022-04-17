class Subscriber < ApplicationRecord
  has_many :sites, dependent: :destroy
  has_many :subscriptions, through: :sites

  # per http://stackoverflow.com/questions/201323/using-a-regular-expression-to-validate-an-email-address
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create}

  before_create :set_confirmation_token

  def self.dates_active
    Date.new(Date.current.year, 4, 1)..Date.new(Date.current.year, 9, 30)
  end

  def self.active?
    dates_active === Date.current
  end
  
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
    Rails.logger.info "Subscriber :: Sending daily mail for #{Date.current.to_s}..."
    Subscription.enable_all if Date.current == dates_active.first
    
    if Subscription.enabled.size > 0
      send_subscriptions(Subscriber.all)
    else
      Rails.logger.info "Subscriber :: No active subscriptions to send for #{date.to_s}"
    end

    Subscription.disable_all if Date.current == dates_active.last
  end

  def self.send_subscriptions(subscribers)
    subscribers = subscribers.is_a?(Subscriber) ? [subscribers] : subscribers

    date = Date.yesterday
    dates = (date - 6.days)..date

    # collect data
    all_sites = Site.where(subscriber: subscribers, enabled: true)

    if all_sites.size > 0
      weather_data = WeatherSub.first.fetch(all_sites)
      ow_data = OakWiltSub.first.fetch(all_sites)

      # send emails to each subscriber with their sites
      subscribers.each do |subscriber|
        sites = subscriber.sites.enabled.joins(:subscriptions)
        data = {}
        weather_sites = sites.where(subscriptions: {type: "WeatherSub"})
        ow_sites = sites.where(subscriptions: {type: "OakWiltSub"})

        data[:weather_data] = weather_sites.collect do |site|
          name, lat, long = site.name, site.latitude, site.longitude
          {
            name:, lat:, long:,
            data: weather_data[[lat, long].to_s]
          }
        end
        
        data[:ow_data] = ow_sites.collect do |site|
          name, lat, long = site.name, site.latitude, site.longitude
          {
            name:, lat:, long:,
            data: ow_data[[lat, long].to_s]
          }
        end

        SubscriptionMailer.daily_mail(subscriber, date, data).deliver
      end
    end
  end

  def fetch_sites(sites)
    weather_data = WeatherSub.first.fetch
    ow_data = OakWiltSub.first.fetch
    # dd_data = Degree
    data = sites.collect do |site|
      lat = site.latitude
      long = site.longitude
      site_key = [lat, long].to_s
      {
        site_name: site.name,
        lat: lat,
        long: long,
        weather_data: weather_data[site_key],
        oak_wilt_data: ow_data[site_key],
        dd_data: dd_data[site_key]
      }
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

  def self.report
    msg = ["Subscribers report"]
    subscribers = Subscriber.all
    summary = {
      subscribers: subscribers.size,
      sites: Site.all.size,
      subscriptions: Subscription.all.size
    }
    subscribers.order(:id).each do |subscriber|
      msg << "\n#{subscriber.id}. #{subscriber.name} (#{subscriber.email})"
      sites = subscriber.sites
      sites.order(:id).each do |site|
        msg << "   #{site.id}. #{site.name} (#{site.latitude}, #{site.longitude})"
        subscriptions = site.subscriptions
        subscriptions.order(:id).each do |subscription|
          msg << "      #{subscription.id}. #{subscription.name}"
        end
      end
    end
    msg.each { |m| puts m }
    summary
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
