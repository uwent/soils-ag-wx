class Subscriber < ApplicationRecord
  has_many :sites, dependent: :destroy
  has_many :subscriptions, through: :sites

  # per http://stackoverflow.com/questions/201323/using-a-regular-expression-to-validate-an-email-address
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}, presence: true
  validates_uniqueness_of :email
  validates :name, presence: true, length: {maximum: 50}

  before_create :set_auth_token
  before_save { email.downcase! }

  def self.dates_active
    Date.new(Date.current.year, 3, 15)..Date.new(Date.current.year, 11, 1)
  end

  def self.active?
    dates_active === Date.current
  end

  # def self.fractional_part(float)
  #   float.to_s =~ /0\.(.+)$/
  #   $1
  # end

  # def self.confirmation_number
  #   fractional_part(rand)
  # end

  def self.find_by_email(email)
    where("lower(email) = ?", email.downcase).first
  end

  def is_confirmed?
    !confirmed_at.nil?
  end

  def confirm!(token)
    if token == auth_token
      self.confirmed_at = Time.current
      save!
      true
    else
      false
    end
  end

  def generate_validation_token
    self.validation_token = rand.to_s[2..7]
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
    Rails.logger.info "Subscriber :: Sending daily mail for #{Date.current}..."
    subscribers = Subscriber.where(emails_enabled: true)
    send_subscriptions(subscribers)
  end

  def self.send_subscriptions(subscribers)
    date = Date.yesterday
    subscribers = subscribers.is_a?(Subscriber) ? [subscribers] : subscribers
    all_sites = Site.where(subscriber: subscribers, enabled: true)

    if all_sites.size == 0
      Rails.logger.warn "Subscriber :: Unable to send any subscriptions, no sites enabled."
      return
    end

    # send emails to each subscriber with their sites
    subscribers.each do |subscriber|
      Rails.logger.debug "\n# Subscriber: #{subscriber.name} #\n"
      sites = subscriber.sites.enabled
      next if sites.size == 0

      # data is an array of hashes where each site is a hash
      data = sites.collect do |site|
        Rails.logger.debug "\n## Site: #{site.full_name} ##\n"

        # subscription list for each site is an array of hashes
        # subscription data is a hash
        site_data = site.subscriptions.collect do |s|
          Rails.logger.debug "\n### Subscription: #{s.name}, partial: #{s.partial} ###"
          sub_data = s.fetch(site)
          {
            name: s.name,
            partial: s.partial,
            options: s.options,
            data: sub_data || {}
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

  private

  def set_auth_token
    self.auth_token = SecureRandom.hex(10)
  end
end
