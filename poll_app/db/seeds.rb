# このファイルは、rails db:seed コマンドを実行したときに実行されます。

# ===============================================
# 1. ユーザーの作成
# ===============================================

puts "初期ユーザーを作成中..."

# ユーザー認証モデルをUserと想定しています。
# 実際には、環境変数などからパスワードを取得する方が安全ですが、今回はデバッグ用にシンプルにします。

user_data = [
  { email: "admin@example.com", password: "password", password_confirmation: "password" },
  { email: "voter1@example.com", password: "password", password_confirmation: "password" }
]

users = user_data.map do |data|
  # User.find_or_create_by を使用して、既に存在する場合はスキップします
  User.find_or_create_by!(email: data[:email]) do |user|
    user.password = data[:password]
    user.password_confirmation = data[:password_confirmation]
  end
end

admin_user = users.first
voter_user = users.last

puts "ユーザー作成完了: #{users.count} 名"
puts "管理者ユーザーID: #{admin_user.id}"


# ===============================================
# 2. アンケートと選択肢の作成
# ===============================================

puts "初期アンケートを作成中..."

# choices_attributes を使用して、ネストされた選択肢を持つアンケートを作成します
poll_data = [
  {
    title: "リモートワーク、週何日派ですか？",
    status: "公開中",
    choices_attributes: [
      { content: "週5日（フルリモート）" },
      { content: "週2〜3日（ハイブリッド）" },
      { content: "週1日以下（ほぼ出社）" },
      { content: "出社のみ" }
    ]
  },
  {
    title: "次に行くなら海？山？",
    status: "公開中",
    choices_attributes: [
      { content: "海派！" },
      { content: "山派！" },
      { content: "インドア派..." }
    ]
  },
]

polls = poll_data.map do |data|
  Poll.find_or_create_by!(title: data[:title]) do |poll|
    poll.user = admin_user
    poll.status = data[:status]
    poll.choices_attributes = data[:choices_attributes]
  end
end

puts "アンケート作成完了: #{polls.count} 件"


# ===============================================
# 3. ダミー投票の作成 (オプション)
# ===============================================

puts "ダミー投票を作成中..."

# 最初のアンケートに投票する
Poll.first.votes.find_or_create_by!(user: voter_user) do |vote|
  # 最初の選択肢に投票
  vote.chosen_option_content = Poll.first.choices.first.content
end

puts "初期データ投入が完了しました。"