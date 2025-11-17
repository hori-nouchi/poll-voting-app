# app/controllers/users_controller.rb
class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  # GET /users/new (新規登録フォームの表示)
  def new
    @user = User.new 
  end
  
  # POST /users (新規ユーザーの作成)
  def create
    @user = User.new(user_params)
    
    if @user.save
      # 登録成功時の処理
      session[:user_id] = @user.id 
      flash[:success] = "登録が完了しました！"
      redirect_to root_path
    else
      # 登録失敗時 (バリデーションエラーなど) の処理
      # render :new を使用しているか確認
      flash.now[:error] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    # パスワードの確認用フィールドを許可しているか確認
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end