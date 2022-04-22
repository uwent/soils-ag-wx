class Subscription < ApplicationRecord
  has_many :site_subscriptions, dependent: :destroy
  has_many :sites, through: :site_subscriptions
  default_scope {order(:id)}
  scope :enabled, -> {where(enabled: true)}

  def self.weather
    select { |s| s.is_a? WeatherSub }
  end

  def self.degree_days
    select { |s| s.is_a? DegreeDaySub }
  end

  def self.pests
    select { |s| s.is_a? PestSub }
  end

  private

  def date_fmt(date)
    date.is_a?(Date) ? date.strftime("%a, %b %-d") : "Unknown date"
  end
  
  def num_fmt(num, digits = 1)
    num.nil? ? "No data" : sprintf("%.#{digits}f", num)
  end
end
