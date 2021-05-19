class AddConfirmedAtToSubscriber < ActiveRecord::Migration[4.2]
  def change
    add_column :subscribers, :confirmed_at, :datetime
    rename_column :subscribers, :confirmed, :confirmation_token
  end
end
