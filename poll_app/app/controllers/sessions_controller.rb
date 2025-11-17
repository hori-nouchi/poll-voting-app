class SessionsController < ApplicationController
  #skip_before_action :verify_authenticity_token, only: [:create, :destroy]
  # ログインフォームの表示 (GET /login)
  def new
    # フォームを表示するだけ
  end

  # ログインの実行 (POST /login)
  def create
    # 1. emailでユーザーを検索
    user = User.find_by(email: params[:email])
    
    # 2. ユーザーが存在し、パスワードが一致するか検証
    # has_secure_passwordによって提供されるauthenticateメソッドを使用
    if user && user.authenticate(params[:password])
      # 3. 認証成功: セッションを作成し、ユーザーIDを保存
      session[:user_id] = user.id
      flash[:success] = "ログインに成功しました！"
      redirect_to root_path
    else
      # 4. 認証失敗: エラーメッセージを表示し、フォームを再表示
      flash.now[:error] = "メールアドレスまたはパスワードが正しくありません。"
      render :new, status: :unprocessable_entity
    end
  end

  # ログアウトの実行 (DELETE /logout)
  def destroy
    # セッションからuser_idを削除
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました。"
    redirect_to root_path, status: :see_other
  end
end