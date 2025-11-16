class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :poll, null: false, foreign_key: true
      t.string :chosen_option

      t.timestamps
    end
    # 複合キー (user_id と poll_id の組み合わせは一意) を設定
    add_index :votes, [:user_id, :poll_id], unique: true
  end
end