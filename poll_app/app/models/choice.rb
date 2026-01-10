class Choice < ApplicationRecord
  # アンケート (Poll) 関連付け
  belongs_to :poll, inverse_of: :choices
  
  # 投票 (Votes) 関連付け
  # 🚨 修正: foreign_key を :choice_id (デフォルト) に戻す 🚨
  # 以前は :chosen_option になっていましたが、これは Vote モデルの規約に反します。
  has_many :votes, dependent: :destroy 
  
  # バリデーション
  validates :content, presence: true, length: { maximum: 100 }, unless: -> { _destroy == "1" || _destroy == true }
end
