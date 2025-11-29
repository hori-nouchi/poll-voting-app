class HomeController < ApplicationController
  def index
    # 1. アンケート一覧（検索対応）
    # ベースクエリ: 公開中のアンケートを、関連ユーザー情報込みで作成日時降順に取得
    @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)

    # 検索クエリがあれば、タイトルで絞り込みを行う
    if params[:search].present?
      # `where` 句を使用して、タイトルに検索キーワードを含むアンケートにフィルタリング
      # 大文字・小文字を区別しない検索が必要な場合は `ILIKE` を使用しますが、
      # ここでは一般的な `LIKE` を使用します。
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end

    # 2. 人気ランキング（総投票数順）
    # left_joinsでVotesがないPollも含め、グループ化して投票数で降順に並び替え、上位5件を取得
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end
  
  # ヘルプページ用のアクション
  def help
    # ビューを表示するだけ
  end
end