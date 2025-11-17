class HomeController < ApplicationController
  def index
    # 🚨 【修正箇所1】 @pollsの初期取得 🚨
    # 通常のアンケート一覧データを取得 (polls#indexと同じロジック)
    # 検索処理を行うために、まず公開中のすべてのアンケートを取得
    @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)

    # 🚨 【修正箇所2】 検索ロジックの追加 🚨
    if params[:search].present?
      # タイトルに検索キーワードを含むアンケートにフィルタリング
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end

    # 投票数順のランキングデータを取得 (既存のコード)
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end
  
  
  # ヘルプページ用のアクションを追加
  def help
    # ビューを表示するだけ
  end
end