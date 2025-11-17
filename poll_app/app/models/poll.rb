class Poll < ApplicationRecord
  # ユーザー関連付け
  belongs_to :user
  
  # 選択肢 (Choices) の関連付け
  # dependent: :destroy は、アンケートが削除されたときに紐づく選択肢も削除することを意味します
  has_many :choices, dependent: :destroy
  
  # 🚨 【重要】ネストされたフォームを許可する設定 🚨
  # これにより、choices_attributesを受け取り、動的な追加・削除（_destroy）を処理できるようになります
  accepts_nested_attributes_for :choices, allow_destroy: true
  
  # 投票 (Votes) の関連付け
  has_many :votes, dependent: :destroy

  # バリデーション
  # 1. title: 必須、最大255文字 (既存のバリデーションに合わせました)
  validates :title, presence: true, length: { maximum: 255 } 
  
  # 2. status: 「公開中」または「終了」のいずれかであること
  validates :status, presence: true, 
                     inclusion: { in: %w(公開中 終了) }
  
  # 🚨 3. choices: 必須、2個以上の項目があること (カスタムバリデーションで処理) 🚨
  validate :must_have_at_least_two_choices

  private
  
  # 選択肢のバリデーション (choices 関連付けのレコードが2つ以上存在するかチェック)
  def must_have_at_least_two_choices
    # marked_for_destruction? が付いていない（つまり削除されない）有効な選択肢を数える
    if choices.reject(&:marked_for_destruction?).size < 2
      # errors.add(:base, ...) ではなく、ネストされたフォームのフィールドに関連付けるため :choices にエラーを追加
      errors.add(:choices, "は最低2つ必要です。")
    end
  end
end