class Insol < ApplicationRecord
  include GridDb
  include Assessable

  def self.date_sym
    :date
  end

  def self.base_url
    self.insolations_url
  end

  def self.endpoint_attribute_name
    'value'
  end
end
