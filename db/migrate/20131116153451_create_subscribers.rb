class CreateSubscribers < ActiveRecord::Migration[4.2]
  def change
    create_table :subscribers do |t|
      t.string :name
      t.string :email
      t.string :confirmed

      t.timestamps
    end
  end
end
