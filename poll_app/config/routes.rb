Rails.application.routes.draw do
  # ホームと静的ページ
  root 'home#index'
  get '/help', to: 'home#help'

  # ユーザー登録 (新規作成)
  # :new, :create のみを定義（show, edit, update, destroyは不要）
  resources :users, only: [:new, :create]
  # 慣用的なパスとしてのエイリアス
  get '/signup', to: 'users#new'
  
  # ログイン/ログアウト (SessionsController)
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # アンケート機能 (PollsController)
  resources :polls do
    member do
      # 投票処理 (POST /polls/:id/vote)
      # 投票を実行するアクション。ヘルパーメソッドは poll_vote_path(@poll)
      post 'vote', to: 'polls#create_vote', as: 'vote' 
      
      # 結果表示 (GET /polls/:id/result)
      # 結果を確認するアクション。ヘルパーメソッドは result_poll_path(@poll) または poll_result_path(@poll)
      get 'result'
    end
  end
  
  # Health check route (Railsのデフォルト)
  get "up" => "rails/health#show", as: :rails_health_check
end