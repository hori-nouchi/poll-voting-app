Rails.application.routes.draw do
  # ホームと静的ページ
  root 'home#index'
  get '/help', to: 'home#help'

  # ユーザー登録 (UsersController)
  # /signup で登録画面を表示し、POST送信も /signup で受け取ります
  get  '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  
  # ログイン/ログアウト (SessionsController)
  get    '/login',  to: 'sessions#new'     # ログインフォーム
  post   '/login',  to: 'sessions#create'  # ログイン実行
  delete '/logout', to: 'sessions#destroy' # ログアウト実行

  # アンケート機能 (PollsController)
  # resources を使うことで、index, show, new, create, edit, update, destroy が自動生成されます
  resources :polls do
    member do
      # 投票処理 (POST /polls/:id/vote)
      # コントローラー内の create_vote メソッドを呼び出します
      post 'vote', to: 'polls#create_vote', as: 'vote' 
      
      # 結果表示 (GET /polls/:id/result)
      get 'result'
    end
  end
  
  # Health check route (Rails 7.1以降のデフォルト)
  get "up" => "rails/health#show", as: :rails_health_check
end