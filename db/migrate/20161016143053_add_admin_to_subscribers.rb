class AddAdminToSubscribers < ActiveRecord::Migration[4.2]
  def change
    add_column :subscribers, :admin, :boolean, default: false
  end
end
