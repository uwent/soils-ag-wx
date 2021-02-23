class AddValidationInfoToSubscribers < ActiveRecord::Migration[4.2]
  def change
    add_column :subscribers, :validation_token, :string
    add_column :subscribers, :validation_created_at, :datetime
  end
end
