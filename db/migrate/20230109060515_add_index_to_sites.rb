class AddIndexToSites < ActiveRecord::Migration[7.0]
  def change
    add_index :sites, [:subscriber_id, :latitude, :longitude], unique: true
  end
end
