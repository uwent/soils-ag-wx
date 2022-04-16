class Subscription < ApplicationRecord
  has_many :site_subscriptions, dependent: :destroy
  has_many :sites, through: :site_subscriptions
  default_scope {order(:id)}
  scope :enabled, -> {where(enabled: true)}
end
