class AddSubscriptionSwitchToSubscribers < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :emails_enabled, :boolean, default: true, null: false
    change_column_null :sites, :name, false
    change_column_null :sites, :latitude, false
    change_column_null :sites, :longitude, false
    change_column_null :subscribers, :name, false, "Subscriber"
    change_column_null :subscribers, :email, false
  end
end
