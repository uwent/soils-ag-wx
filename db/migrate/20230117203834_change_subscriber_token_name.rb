class ChangeSubscriberTokenName < ActiveRecord::Migration[7.0]
  def change
    rename_column :subscribers, :confirmation_token, :auth_token
  end
end
