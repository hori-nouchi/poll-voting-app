class Poll < ApplicationRecord
  # ユーザー関連付け
  belongs_to :user
  
  # 選択肢 (Choices) の関連付け
  has_many :choices, dependent: :destroy
  
  # -----------------------------------------------
  # 🚨 【必須】 reject_if: :all_blank を追加 🚨
  accepts_nested_attributes_for :choices, 
                                allow_destroy: true,
                                reject_if: :all_blank # 空のフィールドを無視
  # -----------------------------------------------
  
  # 投票 (Votes) の関連付け
  has_many :votes, dependent: :destroy

  # バリデーション
  validates :title, presence: true, length: { maximum: 255 } 
  validates :status, presence: true, 
                     inclusion: { in: %w(公開中 終了) }
  
  # 選択肢は最低2つ必須のカスタムバリデーション
  validate :must_have_at_least_two_choices

  private
  
  # 選択肢のバリデーション (choices 関連付けのレコードが2つ以上存在するかチェック)
  def must_have_at_least_two_choices
    # 🚨 修正ロジック 🚨
    # `marked_for_destruction?` (削除フラグが立っているレコード) を除外した後の有効な選択肢をカウントする
    valid_choices_count = choices.reject(&:marked_for_destruction?).size
    
    if valid_choices_count < 2
      # バリデーションエラーが起きた場合、choices にエラーを追加します。
      errors.add(:choices, "は最低2つ必要です。")
    end
  end
end