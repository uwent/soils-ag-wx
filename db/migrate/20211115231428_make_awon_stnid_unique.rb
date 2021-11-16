class MakeAwonStnidUnique < ActiveRecord::Migration[6.1]
  def change
    add_index :awon_stations, :stnid, unique: true
  end
end
