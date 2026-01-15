class PollsController < ApplicationController
  before_action :set_poll, only: [:show, :edit, :update, :destroy, :create_vote, :result]
  before_action :require_login, only: [:new, :create, :edit, :update, :destroy]

  # GET /polls
  def index
    @polls = Poll.all.order(created_at: :desc)
  end

  # GET /polls/:id
  def show
    @choices = @poll.choices
  end

  # GET /polls/new
  def new
    @poll = Poll.new
    # Build 3 default choices for the form
    3.times { @poll.choices.build }
  end

  # POST /polls
  def create
    @poll = current_user.polls.build(poll_params)
    if @poll.save
      redirect_to @poll, notice: 'アンケートを作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /polls/:id/edit
  def edit
  end

  # PATCH/PUT /polls/:id
  def update
    if @poll.update(poll_params)
      redirect_to @poll, notice: 'アンケートを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /polls/:id
  def destroy
    @poll.destroy
    redirect_to polls_url, notice: 'アンケートを削除しました。'
  end

  # POST /polls/:id/vote
  # This matches the route: post 'polls/:id/vote', to: 'polls#create_vote'
  def create_vote
    choice_id = params[:choice_id]

    if choice_id.blank?
      flash[:error] = "選択肢を選んでください。"
      return redirect_to poll_path(@poll)
    end

    @choice = @poll.choices.find_by(id: choice_id)

    if @choice
      # Record user ID if logged in, otherwise anonymous vote
      vote = @choice.votes.build(user: current_user)
      
      if vote.save
        flash[:notice] = "投票が完了しました。"
        redirect_to result_poll_path(@poll)
      else
        flash[:error] = "投票の保存に失敗しました。"
        redirect_to poll_path(@poll)
      end
    else
      flash[:error] = "無効な選択肢です。"
      redirect_to poll_path(@poll)
    end
  end

  # GET /polls/:id/result
  def result
    @choices = @poll.choices.includes(:votes)
  end

  private

  def set_poll
    @poll = Poll.find(params[:id])
  end

  def poll_params
    params.require(:poll).permit(:title, :description, choices_attributes: [:id, :content, :_destroy])
  end

  # Login check
  def require_login
    unless logged_in?
      flash[:error] = "この操作にはログインが必要です。"
      redirect_to login_path
    end
  end

  # Helper to get current user
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  # Ensure helpers are available in views
  helper_method :current_user, :logged_in?
end