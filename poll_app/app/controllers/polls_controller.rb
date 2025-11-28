class PollsController < ApplicationController
  # CSRFトークンの検証スキップは、フォーム送信を伴うアクションでのみ必要
  #skip_before_action :verify_authenticity_token, only: [:create_vote]
  
  # ログイン必須のアクションを定義
  before_action :require_user, except: [:index, :show, :result] 
  
  # 特定のアンケートが必要なアクション
  before_action :set_poll, only: [:show, :result, :create_vote] 

  # GET /polls (アンケート一覧ページ)
  def index
    @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)
    if params[:search].present?
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end
    
    # 投票数ランキング (上位5件)
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end

  # GET /polls/new (新規作成フォーム)
  def new
    # 🚨 修正点: @poll インスタンス変数を初期化する 🚨
    # これが _form.html.erb で必要とされていたオブジェクトです。
    @poll = Poll.new 
    
    # フォームに最低2つの選択肢を持たせるため、関連付けも初期化します。
    # アンケートの仕様に合わせて適切な数（例：2つ）を初期化してください。
    2.times { @poll.choices.build } 
  end

  # POST /polls (新規ユーザーの作成)
  def create
    # current_userと関連付けてアンケートを構築
    @poll = current_user.polls.build(poll_params)
    
    if @poll.save
      flash[:success] = "新しいアンケートを作成しました！"
      redirect_to @poll
    else
      # 失敗した場合、render :new でフォームを再表示
      # choices の build がないとフォームが崩れる可能性があるため、再度初期化
      if @poll.choices.empty?
        2.times { @poll.choices.build } 
      end
      flash.now[:error] = "アンケートの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # GET /polls/:id (投票ページ)
  def show
    # 投票済みチェック
    if logged_in? && Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      logger.info "DEBUG: showアクション内で投票済みを検知。結果ページへリダイレクトを試行。"
      redirect_to result_poll_path(@poll) and return
    end
    
    @vote = Vote.new
  end
  
  # POST /polls/:id/vote (投票処理)
  def create_vote
    # 1. 認証チェック
    unless logged_in?
      flash[:error] = "投票を行うにはログインが必要です。"
      logger.info "DEBUG: 投票失敗 - 未ログインユーザー。"
      redirect_to login_path and return
    end

    # 2. 選択肢未選択チェック
    unless params[:chosen_option].present?
      flash[:error] = "投票する選択肢を選んでください。"
      logger.info "DEBUG: 投票失敗 - 選択肢が未選択。"
      redirect_to poll_path(@poll) and return
    end

    # 3. 二重投票チェック
    if Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。結果を表示します。"
      logger.info "DEBUG: 投票失敗 - 二重投票を検知しました。"
      redirect_to result_poll_path(@poll) and return
    end
    
    # 4. 投票オブジェクトの作成と保存
    @vote = @poll.votes.build(user: current_user, chosen_option: params[:chosen_option])
    
    if @vote.save
      flash[:success] = "投票が完了しました！"
      logger.info "DEBUG: 投票成功。結果ページへリダイレクトを試行。"
      redirect_to result_poll_path(@poll) and return
    else
      logger.error "DEBUG: 投票保存失敗。エラー: #{@vote.errors.full_messages.to_sentence}"
      flash[:error] = "投票の処理中にエラーが発生しました: #{@vote.errors.full_messages.to_sentence}"
      redirect_to poll_path(@poll), status: :unprocessable_entity and return
    end
  end

  # GET /polls/:id/result (投票結果ページ)
  def result
    # 選択肢IDごとの投票数を集計 (例: {1 => 10, 2 => 5})
    vote_counts_by_id = @poll.votes.group(:chosen_option).count
    
    # 選択肢IDをキー、Choiceオブジェクトを値とするハッシュを作成
    choices_map = @poll.choices.index_by(&:id)

    # @results を、選択肢のテキストをキーとするハッシュに変換
    @results = vote_counts_by_id.map do |choice_id, count|
      choice = choices_map[choice_id]
      # 存在しない選択肢IDがvotesテーブルに残っている可能性を考慮
      content = choice ? choice.content : "不明な選択肢 (ID: #{choice_id})"
      [content, count]
    end.to_h
    
    @total_votes = @poll.votes.count 
    logger.info "DEBUG: resultアクション実行。総投票数: #{@total_votes}"
  end

  private
  
  # IDからアンケートオブジェクトを取得し、@pollに代入する共通メソッド
  def set_poll
    @poll = Poll.includes(:choices, :votes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    logger.error "Poll not found with ID: #{params[:id]}"
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  # ストロングパラメータ (セキュリティ対策)
  def poll_params
    # 🚨 修正: choices_attributes を通して、ネストした選択肢の作成を許可 🚨
    params.require(:poll).permit(:title, :description, choices_attributes: [:id, :content, :_destroy])
  end
  
  # current_user の存在チェック（仮定義）
  # NOTE: この定義は ApplicaionController に移動するのがベストプラクティスです。
  def logged_in?
    !!current_user
  end
end