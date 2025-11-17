class Choice < ApplicationRecord
  # アンケート (Poll) 関連付け
  belongs_to :poll
  
  # 投票 (Votes) 関連付け
  # 選択肢が削除された場合、その選択肢に対する投票も削除されます
  has_many :votes, foreign_key: :chosen_option, dependent: :destroy
  
  # バリデーション
  validates :content, presence: true, length: { maximum: 100 }
end