class WiMnDMinTAir < ApplicationRecord
  include GridDb
  include Assessable

  def self.date_sym
    :date
  end

  def self.base_url
    self.weather_url
  end

  def self.endpoint_attribute_name
    'min_temp'
  end
end
