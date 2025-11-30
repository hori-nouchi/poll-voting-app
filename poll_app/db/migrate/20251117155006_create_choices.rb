class CreateChoices < ActiveRecord::Migration[7.0]
  def change
    create_table :choices do |t|
      # 選択肢の内容
      t.string :content, null: false
      
      # 外部キー: どのPollに属するか (Pollモデルとの関連付け)
      # foreign_key: true と null: false を設定
      t.references :poll, null: false, foreign_key: true

      t.timestamps
    end
  end
end