# config/routes.rb

Rails.application.routes.draw do
  # ホームと静的ページ
  root 'home#index'
  get '/help', to: 'home#help'

  # ユーザー登録 (新規作成)
  resources :users, only: [:new, :create]
  get '/register', to: 'users#new'
  
  # ログイン/ログアウト (SessionsController)
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # アンケート機能 (PollsController)
  resources :polls do
    member do
      # 投票処理 (POST /polls/:id/vote)
      # これにより、poll_vote_path(@poll) が使えるようになります
      post 'vote', to: 'polls#create_vote', as: 'vote' 
      
      # 結果表示 (GET /polls/:id/result)
      get 'result'
    end
  end
end