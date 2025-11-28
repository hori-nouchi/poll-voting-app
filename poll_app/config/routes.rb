Rails.application.routes.draw do
  # ホームと静的ページ
  root 'home#index'
  get '/help', to: 'home#help'

  # ユーザー登録 (UsersController)
  # GET /users/new -> users#new (新規登録フォーム)
  # POST /users   -> users#create (ユーザー作成処理)
  #resources :users, only: [:new, :create]
  
  # 慣用的なエイリアス (フォーム表示用)
  # フォームの送信先は users_path (POST /users) を使用するため、
  # POST /signup の定義は不要です。
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  
  # ログイン/ログアウト (SessionsController)
  get '/login', to: 'sessions#new'        # GET /login (ログインフォーム)
  post '/login', to: 'sessions#create'    # POST /login (ログイン実行)
  delete '/logout', to: 'sessions#destroy' # DELETE /logout (ログアウト実行)

  # アンケート機能 (PollsController)
  resources :polls do
    member do
      # 投票処理 (POST /polls/:id/vote)
      post 'vote', to: 'polls#create_vote', as: 'vote' 
      
      # 結果表示 (GET /polls/:id/result)
      get 'result'
    end
  end
  
  # Health check route (Railsのデフォルト)
  get "up" => "rails/health#show", as: :rails_health_check
end