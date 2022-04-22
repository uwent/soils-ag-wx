class Site < ApplicationRecord
  belongs_to :subscriber
  has_many :site_subscriptions, dependent: :destroy
  has_many :subscriptions, through: :site_subscriptions
  default_scope {order(latitude: :desc)}
  scope :enabled, -> {where(enabled: true)}

  def full_name
    "#{name} (#{latitude}, #{longitude})"
  end

  def self.enable_all
    all.update(enabled: true)
  end

  def self.disable_all
    all.update(enabled: false)
  end

  def as_json(options = {})
    {id:, name:, latitude:, longitude:}
  end
end
