class PollsController < ApplicationController
  # 【重要】本番デプロイ前にこの行は必ず削除（またはコメントアウト）してください
  #skip_before_action :verify_authenticity_token, only: [:create_vote]

  # ログイン必須のアクションを定義
  before_action :require_user, except: [:index, :show, :result] 
  
  # 特定のアンケートが必要なアクション
  before_action :set_poll, only: [:show, :edit, :update, :destroy, :result, :create_vote] 
  
  # 編集・削除権限の確認
  before_action :require_same_user, only: [:edit, :update, :destroy]

  # GET /polls
  def index
    @polls = Poll.all.includes(:user).order(created_at: :desc)
    
    if params[:search].present?
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end
    
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end

  # GET /polls/:id
  def show
    if logged_in? && Vote.exists?(user: current_user, poll: @poll)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      redirect_to result_poll_path(@poll) and return
    end
    @vote = Vote.new
  end

  # GET /polls/new
  def new
    @poll = Poll.new 
    # 初期表示用に2つの空の選択肢を作成
    2.times { @poll.choices.build }
  end
  
  # GET /polls/:id/edit
  def edit
    # 既存の選択肢が2つ未満なら、足りない分だけビルド
    remaining_count = @poll.choices.reject(&:marked_for_destruction?).size
    (2 - remaining_count).times { @poll.choices.build } if remaining_count < 2
  end
  
  # POST /polls
  def create
    @poll = current_user.polls.build(poll_params)
    
    if @poll.save
      flash[:success] = "新しいアンケートを作成しました！"
      redirect_to @poll
    else
      # 🚨 修正：エラー時はそのまま render します。
      # poll_params によって入力された値は @poll に保持されています。
      # 追加で build すると、空の入力欄が増えてバリデーションに悪影響を与えることがあります。
      flash.now[:error] = "アンケートの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /polls/:id
  def update
    if @poll.update(poll_params)
      flash[:success] = "アンケートを更新しました。"
      redirect_to @poll
    else
      flash.now[:error] = "アンケートの更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /polls/:id
  def destroy
    @poll.destroy
    redirect_to polls_url, notice: 'アンケートを削除しました。'
  end
  
  # POST /polls/:id/vote
  def create_vote
    unless logged_in?
      flash[:error] = "投票を行うにはログインが必要です。"
      redirect_to login_path and return
    end

    chosen_option_id = params[:chosen_option]
    unless chosen_option_id.present? && @poll.choices.exists?(chosen_option_id)
      flash[:error] = "投票する選択肢を選んでください。"
      redirect_to poll_path(@poll) and return
    end

    if Vote.exists?(user: current_user, poll: @poll)
      flash[:notice] = "すでに投票済みです。"
      redirect_to result_poll_path(@poll) and return
    end
    
    @vote = @poll.votes.build(user: current_user, choice_id: chosen_option_id)
    
    if @vote.save
      flash[:success] = "投票が完了しました！"
      redirect_to result_poll_path(@poll)
    else
      flash[:error] = "エラーが発生しました: #{@vote.errors.full_messages.to_sentence}"
      redirect_to poll_path(@poll)
    end
  end

  # GET /polls/:id/result
  def result
    vote_counts_by_id = @poll.votes.group(:choice_id).count
    choices_map = @poll.choices.index_by(&:id)
    @results = choices_map.transform_values { |choice| vote_counts_by_id[choice.id] || 0 }
                         .sort_by { |_, count| -count } 
                         .to_h
    @total_votes = @poll.votes.count 
  end

  private
    
  def set_poll
    @poll = Poll.includes(:choices, :votes, :user).find(params[:id]) 
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  def require_same_user
    unless current_user == @poll.user
      flash[:error] = "権限がありません。"
      redirect_to root_path and return # 🚨 and return を追加
    end
  end

  def poll_params
    # 🚨 _destroy を許可していることは非常に重要です
    params.require(:poll).permit(:title, :description, choices_attributes: [:id, :content, :_destroy])
  end
end