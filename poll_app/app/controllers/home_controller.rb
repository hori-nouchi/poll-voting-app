class HomeController < ApplicationController
  def index
    # 1. アンケート一覧
    @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)

    if params[:search].present?
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end

    # 2. 人気ランキング
    # モデルに has_many :votes, through: :choices を書いたことで
    # ここでの .left_joins(:votes) が動作するようになります
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end

  def help
  end
end