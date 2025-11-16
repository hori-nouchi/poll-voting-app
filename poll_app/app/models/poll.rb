class Poll < ApplicationRecord
  # 関連付け
  belongs_to :user # アンケート作成者
  has_many :votes, dependent: :destroy # 投票履歴
  
  # バリデーションの設定 (仕様書草稿に基づく)
  
  # [cite_start]1. title: 必須、最大100文字 [cite: 45]
  validates :title, presence: true, 
                    length: { maximum: 100 }
  
  # [cite_start]2. options: 必須、2個以上の項目があること (JSONカラムのデータが配列であることを想定) [cite: 45]
  validates :options, presence: true
  validate :options_must_have_at_least_two_items # カスタムバリデーション
  
  # [cite_start]3. status: 「公開中」または「終了」のいずれかであること [cite: 45]
  validates :status, presence: true, 
                     inclusion: { in: %w(公開中 終了) }

  # 選択肢の数が2個以上であることを確認するカスタムバリデーション
  private
  def options_must_have_at_least_two_items
    # optionsはJSONとして保存されるが、ここでは配列であることを期待する
    if options.blank? || options.length < 2
      errors.add(:options, "は2個以上必要です")
    end
  end
end