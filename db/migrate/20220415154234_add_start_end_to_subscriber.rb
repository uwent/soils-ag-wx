class AddStartEndToSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :doy_start, :integer
    add_column :subscribers, :doy_end, :integer
    remove_column :sites, :doy_start, :integer
    remove_column :sites, :doy_end, :integer
  end
end
