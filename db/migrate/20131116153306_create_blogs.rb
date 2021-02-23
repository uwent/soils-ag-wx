class CreateBlogs < ActiveRecord::Migration[4.2]
  def change
    create_table :blogs do |t|
      t.date :date
      t.text :content
      t.string :tags, array: true

      t.timestamps
    end
  end
end
