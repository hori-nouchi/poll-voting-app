class PollsController < ApplicationController
  # 認証ヘルパーがあると仮定（現在のコードに合わせて require_user を使用）
  before_action :require_user, except: [:index, :show]
  
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
    
      # 🚨 人気ランキングデータの取得 🚨
      @ranking_polls = Poll.left_joins(:votes)
                           .group(:id)
                           .order('COUNT(votes.id) DESC')
                           .limit(5)
  end

  # GET /polls/:id (投票ページ)
  def show
    # 【機能要件】ログインしていて、かつ投票済みの場合、結果ページへリダイレクト
    # logged_in? と result_poll_path が定義されていると仮定
    if logged_in? && Vote.exists?(user_id: current_user.id, poll_id: @poll.id)
      flash[:notice] = "すでにこのアンケートに投票済みです。"
      redirect_to result_poll_path(@poll) and return
    end
    # 未投票の場合はそのまま投票フォームを表示
  end

  # GET /polls/new (アンケート作成フォームの表示)
  def new
    @poll = Poll.new
    # 🚨 【修正】動的なフォームのために、最低2つのChoiceを初期ビルド 🚨
    # Pollモデルが accepts_nested_attributes_for :choices を設定している必要があります。
    2.times { @poll.choices.build } 
  end

  # POST /polls (アンケートの保存処理)
  def create
    # current_user.polls.buildが適切に定義されていると仮定
    @poll = current_user.polls.build(poll_params)
    @poll.status = "公開中" # 初期状態は「公開中」に設定

    if @poll.save
      flash[:success] = "アンケートを作成しました！"
      redirect_to poll_path(@poll) # 作成後、投票ページへリダイレクト
    else
      # バリデーションエラー時はフォームを再表示
      flash.now[:error] = "アンケートの作成に失敗しました。"
      
      # 🚨 【修正】エラー時に選択肢のフォームが消えないように、不足分をビルド 🚨
      # 新規作成フォームを再表示する際に、フォームが壊れないように、まだ保存されていない選択肢の数を確認し、最低2つあることを保証します。
      while @poll.choices.reject(&:marked_for_destruction?).count < 2
        @poll.choices.build
      end
      
      render :new, status: :unprocessable_entity
    end
  end
  
  # POST /polls/:id/vote (投票処理)
  def create_vote
    # Voteオブジェクトを作成し、現在のユーザーとアンケート、選択肢を紐付ける
    # chosen_optionがChoiceモデルのIDであると仮定
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
    # 選択肢IDごとの投票数を集計 (例: {1 => 10, 2 => 5})
    @results = @poll.votes.group(:chosen_option).count
    # 総投票数
    @total_votes = @poll.votes.count 
    
    # ここで @poll.choices を使って、chosen_option（選択肢ID）を内容（content）に変換するロジックが必要になる場合があります。
  end

  private
  
  # IDからアンケートオブジェクトを取得し、@pollに代入する共通メソッド
  def set_poll
    @poll = Poll.find(params[:id])
  end

  # ストロングパラメータ (セキュリティ対策)
  def poll_params
    # 🚨 【修正】ネストされた選択肢 (choices) を許可する choices_attributes に変更 🚨
    # :id は既存レコードの更新用, :content は選択肢の内容, :_destroy は削除用
    params.require(:poll).permit(:title, choices_attributes: [:id, :content, :_destroy])
  end
  
  # require_user の定義は ApplicationController または別の場所にあると仮定
  # def require_user
  #   unless logged_in?
  #     flash[:error] = "ログインが必要です"
  #     redirect_to login_url
  #   end
  # end

end