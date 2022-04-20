class ChangeSubscriptionsToSites < ActiveRecord::Migration[7.0]
  def change
    rename_table :subscriptions, :sites
  end
end
