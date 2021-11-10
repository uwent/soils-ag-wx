class Product < ApplicationRecord
  has_many :subscriptions

  def description
    name
  end
end
