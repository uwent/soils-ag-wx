class CreateAwonRecordTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :awon_record_types do |t|
      t.integer :rec_id
      t.string :rec_name

      t.timestamps
    end
  end
end
