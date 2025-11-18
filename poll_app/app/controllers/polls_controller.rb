class PollsController < ApplicationController
  # 認証ヘルパーがあると仮定。もし require_user が show や result にかかっているなら外す必要があります。
  #skip_before_action :verify_authenticity_token, only: [:create_vote]
  before_action :require_user, except: [:index, :show, :result] 
  
  before_action :set_poll, only: [:show, :result, :create_vote] 

  # GET /polls (アンケート一覧ページ)
  def index
      @polls = Poll.where(status: '公開中').includes(:user).order(created_at: :desc)
      if params[:search].present?
        @polls = @polls.where("title LIKE ?", "%#{params[:search]}%")
      end
      @ranking_polls = Poll.left_joins(:votes)
                           .group(:id)
                           .order('COUNT(votes.id) DESC')
                           .limit(5)
  end

  # GET /polls/:id (投票ページ)
  def show
    # 🚨 修正: ログイン必須のアンケートの場合 🚨
    # もし投票がログインユーザー限定なら、ここで未ログインを弾く。
    # 今回は仕様に合わせて、投票済みかどうかのチェックを強化します。
    if !logged_in?
      # 未ログインユーザーに対する処理。仕様書では「ログインユーザーは投票できる」ので、
      # 投票フォーム自体は表示するが、投票ボタンの制御はビュー側で行うか、
      # create_vote側でエラーにするのが一般的です。
      # ここでは投票済みチェックのみを行います。
    end

    if logged_in? && Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      # 🚨 重要: ログを追加して、ここでリダイレクトが試みられているか確認 🚨
      logger.info "DEBUG: showアクション内で投票済みを検知。結果ページへリダイレクトを試行。"
      redirect_to result_poll_path(@poll) and return
    end
    
    @vote = Vote.new
  end

  # ... (new と create アクションは省略。変更なしと仮定)
  
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
      redirect_to result_poll_path(@poll) and return # 🚨 ここで遷移するはず
    end
    
    # 4. 投票オブジェクトの作成と保存
    # chosen_option は Choice の ID が入る
    @vote = @poll.votes.build(user: current_user, chosen_option: params[:chosen_option])
    
    if @vote.save
      # 🚨 投票成功 🚨
      flash[:success] = "投票が完了しました！"
      logger.info "DEBUG: 投票成功。結果ページへリダイレクトを試行。"
      # 🚨 ここで遷移するはず 🚨
      redirect_to result_poll_path(@poll) and return
    else
      # 🚨 保存失敗時の処理 🚨
      logger.error "DEBUG: 投票保存失敗。エラー: #{@vote.errors.full_messages.to_sentence}"
      flash[:error] = "投票の処理中にエラーが発生しました: #{@vote.errors.full_messages.to_sentence}"
      # 投票ページに戻し、エラーメッセージを表示
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
      content = choice ? choice.content : "不明な選択肢 (ID: #{choice_id})"
      [content, count]
    end.to_h
    
    @total_votes = @poll.votes.count 
    # 🚨 ログを追加 🚨
    logger.info "DEBUG: resultアクション実行。総投票数: #{@total_votes}"
  end

  private
  
  # IDからアンケートオブジェクトを取得し、@pollに代入する共通メソッド
  def set_poll
    # includes(:choices, :votes) で関連データも同時に取得
    @poll = Poll.includes(:choices, :votes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # ログにエラーを記録し、ユーザーには404ページを表示
    logger.error "Poll not found with ID: #{params[:id]}"
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  # ストロングパラメータ (セキュリティ対策)
  def poll_params
    params.require(:poll).permit(:title, choices_attributes: [:id, :content, :_destroy])
  end
  
  # current_user の存在チェック（仮定義）
  def logged_in?
    !!current_user
  end
end