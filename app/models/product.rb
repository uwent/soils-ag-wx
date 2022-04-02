class Product < ApplicationRecord
  has_many :subscriptions

  def description
    name
  end

  # TODO: this shouldn't be a database class
  # Add default start/end dates to a subclass for the ET mailer
end
