class ApplicationController < ActionController::Base
  # 以下のメソッドをすべてのコントローラーとビューで利用可能にする
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  
  # 現在ログインしているユーザーを取得する
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # ログイン状態か判定する
  def logged_in?
    !!current_user
  end

  # ログインが必須なアクションでのアクセス制限
  def require_user
    unless logged_in?
      flash[:error] = "この操作にはログインが必要です。"
      redirect_to login_path
    end
  end
end