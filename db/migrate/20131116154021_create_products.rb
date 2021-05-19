class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :data_table_name
      t.string :type

      t.timestamps
    end
  end
end
