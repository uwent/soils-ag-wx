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

  def self.enable_weather_subscriptions
    msg = []
    Subscriber.all.each do |subscriber|
      msg << "Subscriber: #{subscriber.name}"
      subscriber.sites.each do |site|
        begin
          site.subscriptions << Subscription.weather
          msg << "  Added weather subscription to " + site.name
        rescue
          msg << "  " + site.name + " is already subscribed"
          next
        end
      end
    end
    puts msg.join("\n")
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

    all_sites = Site.where(subscriber: subscribers, enabled: true)
    return "No sites enabled!" unless all_sites.size > 0

    date = Date.yesterday
    dates = (date - 6.days)..date

    # send emails to each subscriber with their sites
    subscribers.each do |subscriber|
      Rails.logger.debug "\n# Subscriber: #{subscriber.name} #\n"
      sites = subscriber.sites.enabled

      # data is an array of hashes where each site is a hash
      data = sites.collect do |site|
        Rails.logger.debug "\n## Site: #{site.full_name} ##\n"

        # subscriptions for each site is an array of hashes
        site_data = site.subscriptions.collect do |s|
          Rails.logger.debug "\n### Subscription: #{s.name}, partial: #{s.partial} ###"
          {
            name: s.name,
            partial: s.partial,
            options: s.options,
            data: s.fetch(site)
          }
        end

        {
          name: site.name,
          lat: site.latitude,
          long: site.longitude,
          data: site_data
        }
      end

      SubscriptionMailer.daily_mail(subscriber, date, data).deliver
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[ID Name Email DateCreated Admin? Sites SitesEnabled Subscriptions]
      Subscriber.all.order(:id).each do |s|
        csv << [s.id, s.name, s.email, s.created_at, s.admin, s.sites.size, s.sites.enabled.size, s.subscriptions.size]
      end
    end
  end

  def self.report
    msg = ["\n### Subscribers report ###"]
    subscribers = Subscriber.all
    subscriptions = Subscription.all

    summary = {
      subscribers: subscribers.size,
      sites: Site.all.size,
      subs: subscriptions.size,
      site_subs: SiteSubscription.all.size
    }

    subscribers.order(:id).each do |subscriber|
      sites = subscriber.sites

      msg << "\n#{subscriber.id}. #{subscriber.name} (#{subscriber.email}) - " + sites.size.to_s + " sites"
      pad1 = " " * (subscriber.id.to_s.length + 2)

      sites.order(:id).each do |site|
        site_subs = site.subscriptions

        msg << pad1 + "#{site.id}. #{site.name} (#{site.latitude}, #{site.longitude}) - " + site_subs.size.to_s + " subs"
        pad2 = pad1 + " " * (site.id.to_s.length + 2)
        
        site_subs.order(:id).each do |s|
          msg << pad2 + "#{s.id}. #{s.name}"
        end
      end
    end

    msg << "\n### Subscriptions available ###\n"
    subscriptions.order(:id).each do |s|
      msg << "#{s.id}. #{s.name} (#{s.type}) - " + s.sites.size.to_s + " sites"
    end

    msg << "\n### Summary ###\n"
    msg << "Subscribers: #{summary[:subscribers]}"
    msg << "Sites: #{summary[:sites]}"
    msg << "Subscriptions available: #{summary[:subs]}"
    msg << "Site subscriptions: #{summary[:site_subs]}"

    puts msg.join("\n")
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
