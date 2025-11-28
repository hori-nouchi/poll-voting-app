class UsersController < ApplicationController
  # 認証済みユーザーのみが実行できるアクションの制限を、このコントローラーでは解除します。
  # ログインや新規登録は、未認証ユーザーが行うためです。
  #skip_before_action :verify_authenticity_token, only: [:create]

  # GET /users/new (新規登録フォームの表示)
  def new
    # 新しいユーザーオブジェクトを初期化し、フォームに渡します
    @user = User.new 
  end
  
  # POST /users (新規ユーザーの作成)
  def create
    @user = User.new(user_params)
    
    if @user.save
      # 登録成功時の処理: セッションにユーザーIDを保存し、ログイン状態にします
      # 🚨 NOTE: `login(@user)`というヘルパーメソッドが定義されている場合は、
      # 🚨 `session[:user_id] = @user.id` の代わりにそちらを使用することで、SessionsControllerと共通化できます。
      session[:user_id] = @user.id 
      flash[:success] = "登録が完了しました！"
      redirect_to root_path
    else
      # 登録失敗時 (バリデーションエラーなど) の処理
      # フォームの再表示とHTTPステータス422 (処理不能なエンティティ) を返します
      flash.now[:error] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  # ストロングパラメーター
  def user_params
    # 許可する属性: email, password, password_confirmation
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end