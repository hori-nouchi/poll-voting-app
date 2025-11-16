class User < ApplicationRecord
  # has_secure_passwordを使うための設定
  has_secure_password
  
  # Polls と Votes との関連付けを追加 (アンケートと投票機能の実装のため)
  has_many :polls, dependent: :destroy # 作成したアンケート
  has_many :votes, dependent: :destroy # 投票履歴

  # [cite_start]バリデーションの設定 (仕様書草稿に基づく [cite: 40])
  # email: 必須、一意、メールアドレス形式、最大255文字
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false }, 
                    length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # password: 必須、最低8文字以上
  validates :password, length: { minimum: 8 }, 
                       allow_nil: true 
end