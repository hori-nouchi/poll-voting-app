class PollsController < ApplicationController
  # new, create, show, create_vote アクションにログイン必須の制限を適用
  skip_before_action :verify_authenticity_token, only: [:create, :create_vote]
  
  before_action :require_user, except: [:index, :show]
  #before_action :require_user, only: [:new, :create, :show, :create_vote]
  
  # show (投票ページ), result (結果ページ), create_vote (投票処理) でアンケートを特定
  before_action :set_poll, only: [:show, :result, :create_vote] 

  # GET /polls (アンケート一覧ページ)
  def index
      # 「公開中」のアンケートを取得し、作成日時の降順で表示 (通常の一覧)
      @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)

      # 検索機能の実装（タイトル検索）
      if params[:search].present?
        @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
      end
    
     # 🚨 【ここを追加】人気ランキングデータの取得 🚨
      @ranking_polls = Poll.left_joins(:votes)
                           .group(:id)
                           .order('COUNT(votes.id) DESC')
                           .limit(5)
    # これで、投票数が多い順に最大5件のアンケートが @ranking_polls に入ります。
  end

  # GET /polls/:id (投票ページ)
  def show
    # 【機能要件】ログインしていて、かつ投票済みの場合、結果ページへリダイレクト
    if logged_in? && Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      redirect_to result_poll_path(@poll) and return
    end
    # 未投票の場合はそのまま投票フォームを表示
  end

  # GET /polls/new (アンケート作成フォームの表示)
  def new
    @poll = Poll.new
  end

  # POST /polls (アンケートの保存処理)
  def create
    # 現在のユーザーに紐付けてPollオブジェクトを構築
    @poll = current_user.polls.build(poll_params)
    @poll.status = "公開中" # 初期状態は「公開中」に設定

    if @poll.save
      flash[:success] = "アンケートを作成しました！"
      redirect_to poll_path(@poll) # 作成後、投票ページへリダイレクト
    else
      # バリデーションエラー時はフォームを再表示
      flash.now[:error] = "アンケートの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end
  
  # POST /polls/:id/vote (投票処理)
  def create_vote
    # Voteオブジェクトを作成し、現在のユーザーとアンケート、選択肢を紐付ける
    @vote = @poll.votes.build(user: current_user, chosen_option: params[:chosen_option])
    
    if @vote.save
      flash[:success] = "投票が完了しました！"
      redirect_to result_poll_path(@poll) # 投票成功後、結果ページへ
    else
      # バリデーションエラー（主に二重投票防止）
      flash[:error] = "投票に失敗しました。#{@vote.errors.full_messages.to_sentence}"
      redirect_to poll_path(@poll) # 投票ページに戻す
    end
  end

  # GET /polls/:id/result (投票結果ページ)
  def result
    # 【機能要件】投票結果の集計ロジック
    # 選択肢ごとの投票数を集計 (例: {"選択肢A" => 10, "選択肢B" => 5})
    @results = @poll.votes.group(:chosen_option).count
    # 総投票数
    @total_votes = @poll.votes.count 
  end

  private
  
  # IDからアンケートオブジェクトを取得し、@pollに代入する共通メソッド
  def set_poll
    @poll = Poll.find(params[:id])
  end

  # ストロングパラメータ (セキュリティ対策)
  def poll_params
    # titleとoptions (配列) のみを受け取る
    params.require(:poll).permit(:title, options: []) 
  end
end