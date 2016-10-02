class AddValidationInfoToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :validation_token, :string
    add_column :subscribers, :validation_created_at, :datetime
  end
end
