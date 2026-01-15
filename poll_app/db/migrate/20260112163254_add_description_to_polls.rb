class AddDescriptionToPolls < ActiveRecord::Migration[8.1]
  def change
    add_column :polls, :description, :text
  end
end
