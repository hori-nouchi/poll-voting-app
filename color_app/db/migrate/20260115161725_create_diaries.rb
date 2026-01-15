class CreateDiaries < ActiveRecord::Migration[8.1]
  def change
    create_table :diaries do |t|
      t.date :diary_date
      t.string :color
      t.text :content

      t.timestamps
    end
  end
end
