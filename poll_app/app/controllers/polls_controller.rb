class PollsController < ApplicationController
  # 【重要】本番デプロイ前にこの行は必ず削除（またはコメントアウト）してください
  # skip_before_action :verify_authenticity_token, only: [:create_vote]

  # ログイン必須のアクションを定義
  before_action :require_user, except: [:index, :show, :result] 
  
  # 特定のアンケートが必要なアクション
  before_action :set_poll, only: [:show, :edit, :update, :destroy, :result, :create_vote] 

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
    @poll = Poll.new 
    
    # 🚨 修正点 1: 新規作成時、choicesが空の場合にのみ2つビルドする（安全策） 🚨
    # choices が空 (new直後は空) の場合のみ実行します
    if @poll.choices.empty?
      2.times { @poll.choices.build }
    end
  end

  # GET /polls/:id/edit
  def edit
    # 🚨 修正点 2: 編集時、既存の選択肢が2つ未満なら、2つになるまでビルドする 🚨
    # 既存の選択肢がある場合はそのまま表示し、足りない分だけビルドします。
    (2 - @poll.choices.size).times { @poll.choices.build } if @poll.choices.size < 2
  end
  
  # POST /polls (新規アンケートの作成)
  def create
    @poll = current_user.polls.build(poll_params)
    
    if @poll.save
      flash[:success] = "新しいアンケートを作成しました！"
      redirect_to @poll
    else
      # 🚨 修正点 3: 作成失敗時、choicesが2つ未満なら、2つになるまでビルドする 🚨
      # バリデーションエラーで戻る際も、選択肢が消えないようにビルドします。
      (2 - @poll.choices.size).times { @poll.choices.build } if @poll.choices.size < 2
      
      flash.now[:error] = "アンケートの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # GET /polls/:id (投票ページ)
  def show
    if logged_in? && Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      logger.info "DEBUG: showアクション内で投票済みを検知。結果ページへリダイレクトを試行。"
      redirect_to result_poll_path(@poll) and return
    end
    
    @vote = Vote.new
  end

  # PATCH/PUT /polls/:id
  def update
    if @poll.update(poll_params)
      redirect_to @poll, notice: 'アンケートが正常に更新されました。'
    else
      # 🚨 修正点 4: 更新失敗時、choicesが2つ未満なら、2つになるまでビルドする 🚨
      (2 - @poll.choices.size).times { @poll.choices.build } if @poll.choices.size < 2
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /polls/:id
  def destroy
    @poll.destroy
    redirect_to polls_url, notice: 'アンケートが正常に削除されました。'
  end
  
  # POST /polls/:id/vote (投票処理)
  def create_vote
    unless logged_in?
      flash[:error] = "投票を行うにはログインが必要です。"
      logger.info "DEBUG: 投票失敗 - 未ログインユーザー。"
      redirect_to login_path and return
    end

    unless params[:chosen_option].present?
      flash[:error] = "投票する選択肢を選んでください。"
      logger.info "DEBUG: 投票失敗 - 選択肢が未選択。"
      redirect_to poll_path(@poll) and return
    end

    if Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。結果を表示します。"
      logger.info "DEBUG: 投票失敗 - 二重投票を検知しました。"
      redirect_to result_poll_path(@poll) and return
    end
    
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
    vote_counts_by_id = @poll.votes.group(:chosen_option).count
    choices_map = @poll.choices.index_by(&:id)

    @results = vote_counts_by_id.map do |choice_id, count|
      choice = choices_map[choice_id]
      content = choice ? choice.content : "不明な選択肢 (ID: #{choice_id})"
      [content, count]
    end.to_h
    
    @total_votes = @poll.votes.count 
    logger.info "DEBUG: resultアクション実行。総投票数: #{@total_votes}"
  end

  private
  
  def set_poll
    @poll = Poll.includes(:choices, :votes).find(params[:id]) 
  rescue ActiveRecord::RecordNotFound
    logger.error "Poll not found with ID: #{params[:id]}"
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  def poll_params
    params.require(:poll).permit(:title, :description, choices_attributes: [:id, :content, :_destroy])
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_user
    unless logged_in?
      flash[:error] = "この操作を行うにはログインが必要です。"
      redirect_to login_path 
    end
  end
end