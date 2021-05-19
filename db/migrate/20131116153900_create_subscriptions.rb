class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.string :name
      t.integer :subscriber_id
      t.float :latitude
      t.float :longitude
      t.integer :product_id

      t.timestamps
    end
  end
end
