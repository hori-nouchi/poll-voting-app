class AddUserIdToDiaries < ActiveRecord::Migration[8.1]
  def change
    add_column :diaries, :user_id, :integer
  end
end
