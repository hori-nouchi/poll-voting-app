class AddChoiceIdToVotes < ActiveRecord::Migration[8.1]
  def change
    add_reference :votes, :choice, null: false, foreign_key: true
  end
end
