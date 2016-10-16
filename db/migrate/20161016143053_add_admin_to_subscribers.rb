class AddAdminToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :admin, :boolean, default: false
  end
end
