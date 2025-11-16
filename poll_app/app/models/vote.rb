class Vote < ApplicationRecord
  # 関連付け
  belongs_to :user # 投票したユーザー
  belongs_to :poll # 投票されたアンケート
  
  # バリデーションの設定 (仕様書草稿に基づく)
  
  # [cite_start]1. user_id と poll_id の複合一意性 (1ユーザーは1アンケートに1回のみ投票) [cite: 49]
  # これはマイグレーションでインデックスを作成しましたが、ここではモデルでも検証します。
  validates :user_id, uniqueness: { scope: :poll_id, message: "は同じアンケートに二重に投票できません" }
  
  # [cite_start]2. chosen_option: 必須 [cite: 48]
  validates :chosen_option, presence: true
  
  # 投票した選択肢が、該当アンケートの有効な選択肢であることを検証するカスタムバリデーション (発展的な内容)
  # validate :chosen_option_must_be_valid # 必要に応じて追加
end