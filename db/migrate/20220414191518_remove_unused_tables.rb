class RemoveUnusedTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :asos_data do |t|
      t.date :date
      t.time :nominal_time
      t.time :actual_time
      t.integer :asos_station_id
      t.float :t_dew
      t.float :t_air
      t.float :windspeed
      t.float :pressure
      t.float :precip
      t.float :wind_dir
      t.timestamps
    end

    drop_table :asos_stations do |t|
      t.string :stnid
      t.string :state
      t.string :name
      t.string :stn_type
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    drop_table :blogs do |t|
      t.date :date
      t.text :content
      t.string :tags, array: true
      t.timestamps
    end

    drop_table :degree_day_stations do |t|
      t.string :abbrev
      t.string :name
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    drop_table :webcam_images do |t|
      t.datetime :timestamp
      t.string :fname
      t.string :sequence_fname
      t.integer :size
      t.timestamps
    end

    change_table :subscriptions do |t|
      t.remove_references :product
    end

    drop_table :products do |t|
      t.string :name
      t.string :data_table_name
      t.string :type
      t.timestamps
    end
  end
end
