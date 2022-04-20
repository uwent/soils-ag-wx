class SiteSubscription < ApplicationRecord
  belongs_to :site
  belongs_to :subscription
  validates_uniqueness_of :site, scope: [:subscription], on: :create
  validates_uniqueness_of :subscription, scope: [:site], on: :create
end
