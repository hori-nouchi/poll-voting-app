class PollsController < ApplicationController
  # 【重要】本番デプロイ前にこの行は必ず削除（またはコメントアウト）してください
  #skip_before_action :verify_authenticity_token, only: [:create_vote]

  # ログイン必須のアクションを定義
  before_action :require_user, except: [:index, :show, :result] 
  
  # 特定のアンケートが必要なアクション
  before_action :set_poll, only: [:show, :edit, :update, :destroy, :result, :create_vote] 
  
  # 編集・削除権限の確認
  before_action :require_same_user, only: [:edit, :update, :destroy] # 🚨 追記 🚨

  # GET /polls (アンケート一覧ページ)
  def index
    # ベースクエリ: すべてのアンケートを、関連ユーザー情報込みで作成日時降順に取得
    @polls = Poll.all.includes(:user).order(created_at: :desc)
    
    # 検索クエリがあれば、タイトルで絞り込みを行う
    if params[:search].present?
      @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
    end
    
    # 投票数ランキング (上位5件)
    @ranking_polls = Poll.left_joins(:votes)
                         .group(:id)
                         .order('COUNT(votes.id) DESC')
                         .limit(5)
  end

  # GET /polls/:id (投票ページ)
  def show
    # ログイン済みで投票済みの場合は結果ページにリダイレクト
    if logged_in? && Vote.exists?(user: current_user, poll: @poll) # user: current_user を使用
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      logger.info "DEBUG: showアクション内で投票済みを検知。結果ページへリダイレクトを試行。"
      redirect_to result_poll_path(@poll) and return
    end
    
    @vote = Vote.new
  end

  # GET /polls/new (新規作成フォーム)
  def new
    @poll = Poll.new 
    
    # 選択肢が2つ未満の場合に、2つになるまでビルドします
    (2 - @poll.choices.size).times { @poll.choices.build }
  end
  
  # GET /polls/:id/edit
  def edit
    # 編集時、既存の選択肢が2つ未満なら、2つになるまでビルドする
    (2 - @poll.choices.reject(&:marked_for_destruction?).size).times { @poll.choices.build } # 🚨 修正: 削除予定の選択肢を除外 🚨
    require_same_user # 🚨 追記 🚨
  end
  
  # POST /polls (新規アンケートの作成)
  def create
    # current_userと関連付けてアンケートをビルド
    @poll = current_user.polls.build(poll_params)
    
    if @poll.save
      flash[:success] = "新しいアンケートを作成しました！"
      redirect_to @poll
    else
      # 作成失敗時、選択肢が消えないように2つになるまでビルドし直す
      (2 - @poll.choices.reject(&:marked_for_destruction?).size).times { @poll.choices.build } # 🚨 修正: 削除予定の選択肢を除外 🚨
      
      flash.now[:error] = "アンケートの作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /polls/:id
  def update
    require_same_user # 🚨 追記 🚨
    if @poll.update(poll_params)
      redirect_to @poll, notice: 'アンケートが正常に更新されました。'
    else
      # 更新失敗時、選択肢が消えないように2つになるまでビルドし直す
      (2 - @poll.choices.reject(&:marked_for_destruction?).size).times { @poll.choices.build } # 🚨 修正: 削除予定の選択肢を除外 🚨
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /polls/:id
  def destroy
    require_same_user # 🚨 追記 🚨
    @poll.destroy
    redirect_to polls_url, notice: 'アンケートが正常に削除されました。'
  end
  
  # POST /polls/:id/vote (投票処理)
  def create_vote
    # 投票前のログインチェックと選択肢チェック
    unless logged_in?
      flash[:error] = "投票を行うにはログインが必要です。"
      redirect_to login_path and return
    end

    chosen_option_id = params[:chosen_option]
    unless chosen_option_id.present? && @poll.choices.exists?(chosen_option_id)
      flash[:error] = "投票する選択肢を選んでください。"
      redirect_to poll_path(@poll) and return
    end

    # 二重投票チェック (user_idとpoll_idの複合キー制約に基づき、Voteモデルのバリデーションが働くはず)
    if Vote.exists?(user: current_user, poll: @poll)
      flash[:notice] = "すでにこのアンケートに投票済みです。結果を表示します。"
      redirect_to result_poll_path(@poll) and return
    end
    
    # 🚨 【重要】chosen_option ではなく choice_id を使用 🚨
    @vote = @poll.votes.build(user: current_user, choice_id: chosen_option_id)
    
    if @vote.save
      flash[:success] = "投票が完了しました！"
      redirect_to result_poll_path(@poll) and return
    else
      logger.error "DEBUG: 投票保存失敗。エラー: #{@vote.errors.full_messages.to_sentence}"
      flash[:error] = "投票の処理中にエラーが発生しました: #{@vote.errors.full_messages.to_sentence}"
      redirect_to poll_path(@poll), status: :unprocessable_entity and return
    end
  end

  # GET /polls/:id/result (投票結果ページ)
  def result
    # 選択肢ごとの投票数をカウント
    # 🚨 【重要】chosen_option ではなく choice_id でグループ化 🚨
    vote_counts_by_id = @poll.votes.group(:choice_id).count
    # Choice ID と Choice オブジェクトのマップを作成 (投票結果の表示用)
    choices_map = @poll.choices.index_by(&:id)

    # 結果を整形
    @results = choices_map.transform_values { |choice| vote_counts_by_id[choice.id] || 0 }
                       .sort_by { |_, count| -count } 
                       .to_h
    
    @total_votes = @poll.votes.count 
    logger.info "DEBUG: resultアクション実行。総投票数: #{@total_votes}"
  end

  private
    
  # アンケートオブジェクトを取得
  def set_poll
    # 関連付けられたデータも同時に取得 (N+1問題対策)
    @poll = Poll.includes(:choices, :votes, :user).find(params[:id]) 
  rescue ActiveRecord::RecordNotFound
    logger.error "Poll not found with ID: #{params[:id]}"
    # ユーザーに404ページを表示
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  # ユーザーがアンケートの所有者であるかを確認
  # 🚨 以前のコードにはこのメソッドの定義が欠落していたため、追記 🚨
  def require_same_user
    unless current_user == @poll.user
      flash[:error] = "他のユーザーのアンケートは編集・削除できません。"
      redirect_to root_path
    end
  end

  # ストロングパラメーター
  def poll_params
    params.require(:poll).permit(:title, :description, choices_attributes: [:id, :content, :_destroy])
  end
end