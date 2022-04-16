class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    drop_table :regions do |t|
      t.string :name
      t.string :abbrev
      t.timestamps
    end

    create_table :subscriptions do |t|
      t.string :type
      t.string :name
      t.jsonb :options
      t.boolean :enabled, default: true
      t.timestamps
    end

    create_table :site_subscriptions do |t|
      t.integer :site_id
      t.integer :subscription_id
    end

    add_index :site_subscriptions, [:site_id, :subscription_id], unique: true
  end
end
