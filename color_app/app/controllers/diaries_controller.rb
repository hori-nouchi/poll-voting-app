class DiariesController < ApplicationController
  # ヘルプページ以外はログイン必須
  before_action :authenticate_user!, except: [:help]
  
  # 修正：日記を探すときも「自分の日記」の中から探すように変更
  before_action :set_diary, only: %i[ show edit update destroy ]

  # GET /diaries
  def index
    # 修正：すべての日記ではなく「自分の日記」だけを取得
    @diaries = current_user.diaries
  end

  # GET /diaries/1
  def show
  end

  # GET /diaries/new
  def new
    # 修正：最初から自分のユーザーIDを紐付けた状態で作成
    @diary = current_user.diaries.build
  end

  # GET /diaries/1/edit
  def edit
  end

  # POST /diaries
  def create
    # 修正：ログイン中のユーザーに紐付けて日記を作成
    @diary = current_user.diaries.build(diary_params)

    respond_to do |format|
      if @diary.save
        format.html { redirect_to @diary, notice: "日記を保存しました！" }
        format.json { render :show, status: :created, location: @diary }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diaries/1
  def update
    respond_to do |format|
      if @diary.update(diary_params)
        format.html { redirect_to @diary, notice: "日記を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @diary }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @diary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diaries/1
  def destroy
    @diary.destroy!

    respond_to do |format|
      format.html { redirect_to diaries_path, notice: "日記を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /help
  def help
  end

  private
    # 修正：日記を探す範囲を「自分の日記」に限定することでセキュリティを強化
    def set_diary
      @diary = current_user.diaries.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to diaries_path, alert: "指定された日記は見つかりません。"
    end

    # 保存を許可するパラメーター
    def diary_params
      params.require(:diary).permit(:diary_date, :color, :content)
    end
end