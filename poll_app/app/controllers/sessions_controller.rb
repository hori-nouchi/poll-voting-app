class SessionsController < ApplicationController
  # CSRFトークン検証のエラー（422）が再発しないよう、
  # 開発環境で動作を確認しながら進めます。本番環境での運用時は、
  # 以下の `skip_before_action` は使用しないでください。
  #skip_before_action :verify_authenticity_token, only: [:create, :destroy]
  # ログインフォームの表示 (GET /login)
  def new
    # フォームを表示するだけ
  end

  # ログインの実行 (POST /login)
  def create
    # 🚨 デバッグログの開始 🚨
    logger.info "--- ログイン試行開始 ---"
    logger.info "入力メールアドレス: #{params[:email]}"

    # 1. emailでユーザーを検索
    user = User.find_by(email: params[:email])
    
    # 2. ユーザーが存在し、パスワードが一致するか検証
    if user
      logger.info "ユーザー発見: ID=#{user.id}"
      
      # has_secure_passwordのauthenticateメソッドを使用
      if user.authenticate(params[:password])
        # 3. 認証成功
        logger.info "認証成功！セッションを作成します。"
        
        # ログイン処理はApplicationControllerのヘルパーに任せても良いが、
        # ここでは直接セッションを操作します
        session[:user_id] = user.id
        
        flash[:success] = "ログインに成功しました！"
        # 🚨 リダイレクト成功ログ 🚨
        logger.info "--- ログイン試行終了: 成功 ---"
        redirect_to root_path
        return
      else
        # 4. パスワード不一致
        logger.warn "認証失敗: パスワード不一致。"
        flash.now[:error] = "メールアドレスまたはパスワードが正しくありません。"
        logger.info "--- ログイン試行終了: 失敗 (パスワード) ---"
        render :new, status: :unprocessable_entity
      end
    else
      # 5. ユーザー未発見
      logger.warn "認証失敗: ユーザー未発見。新規登録が必要です。"
      flash.now[:error] = "メールアドレスまたはパスワードが正しくありません。"
      logger.info "--- ログイン試行終了: 失敗 (ユーザーなし) ---"
      render :new, status: :unprocessable_entity
    end
  end

  # ログアウトの実行 (DELETE /logout)
  def destroy
    # セッションからuser_idを削除
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました。"
    # ログアウト後のリダイレクトは status: :see_other を付けるのが慣例
    redirect_to root_path, status: :see_other
  end
end