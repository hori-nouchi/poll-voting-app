# このファイルは、rails db:seed コマンドを実行したときに実行されます。
# 🚨 【修正】エラー耐性を高めるため、強制終了 (!) を含むメソッドを削除しました。
# 🚨 【修正】Voteモデルの属性名を仕様書に合わせ 'chosen_option' に変更しました。

# ===============================================
# 1. ユーザーの作成
# ===============================================

puts "初期ユーザーを作成中..."

user_data = [
  { email: "admin@example.com", password: "password", password_confirmation: "password" },
  { email: "voter1@example.com", password: "password", password_confirmation: "password" }
]

# find_or_create_by を使用 (既に存在する可能性を考慮し、バリデーション失敗時も例外を投げない)
users = user_data.map do |data|
  User.find_or_create_by(email: data[:email]) do |user|
    # パスワードが必須の場合に備えて設定
    user.password = data[:password]
    user.password_confirmation = data[:password_confirmation]
  end
end

# ユーザーが存在しない場合に備えて nil チェック
admin_user = users.first
voter_user = users.last

unless admin_user&.persisted? && voter_user&.persisted?
  # ここで失敗する場合は、Userモデルのバリデーションが厳しすぎる可能性があります
  puts "========================================================"
  puts "🚨 ユーザー作成失敗: Userモデルのバリデーションを確認してください 🚨"
  # 失敗したレコードのエラーメッセージを出力（デバッグ用）
  users.each do |user|
    puts "Email: #{user.email}, Errors: #{user.errors.full_messages.join(', ')}" unless user.persisted?
  end
  puts "========================================================"
  # 強制終了する代わりに、アンケート作成をスキップ
  puts "ユーザーが作成できなかったため、シードの残りの処理をスキップします。"
  return
end

puts "ユーザー作成完了: #{users.count} 名"


# ===============================================
# 2. アンケートと選択肢の作成
# ===============================================

puts "初期アンケートを作成中..."

# Poll.choices.build に対応する属性は、Choiceモデルの属性である必要があります。
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
  # find_or_create_by を使用
  Poll.find_or_create_by(title: data[:title]) do |poll|
    poll.user = admin_user
    poll.status = data[:status]
    poll.choices_attributes = data[:choices_attributes]
  end
end

unless polls.all?(&:persisted?)
  puts "========================================================"
  puts "🚨 アンケート作成失敗: PollまたはChoiceモデルのバリデーションを確認してください 🚨"
  # 失敗したレコードのエラーメッセージを出力（デバッグ用）
  polls.each do |poll|
    puts "Title: #{poll.title}, Errors: #{poll.errors.full_messages.join(', ')}" unless poll.persisted?
  end
  puts "========================================================"
end

puts "アンケート作成完了: #{polls.count} 件"


# ===============================================
# 3. ダミー投票の作成
# ===============================================

puts "ダミー投票を作成中..."

first_poll = Poll.where(status: "公開中").first
first_choice = first_poll&.choices&.first

if first_poll && voter_user && first_choice
  # find_or_create_by を使用し、複合キー制約によるエラーを防ぐ
  Vote.find_or_create_by(user: voter_user, poll: first_poll) do |vote|
    # 🚨 Voteモデルの属性名 'chosen_option' を使用
    vote.chosen_option = first_choice.content
  end
end

puts "初期データ投入が完了しました。"