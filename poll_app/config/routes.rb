Rails.application.routes.draw do
  get "static_pages/help"
  # ホームページの設定
  root 'home#index' 
  # 「Help」ボタンのリンク先を設定
get 'help', to: 'home#help'
  
  # アンケート機能のルーティング
  # Pollsコントローラーのindex, show, new, create, update, destroyに対応
  resources :polls do 
    member do
      get 'result' 
      # 投票処理のためのPOSTルートを追加
      post 'vote', to: 'polls#create_vote', as: :vote 
    end
  end
  
  # ユーザー認証系のルーティング (SessionsコントローラーとUsersコントローラーを使用)
  get '/login', to: 'sessions#new' # ログインフォーム表示
  post '/login', to: 'sessions#create' # ログイン処理
  delete '/logout', to: 'sessions#destroy' # ログアウト処理
  
  get '/register', to: 'users#new', as: :register # 新規登録フォーム表示
  post '/users', to: 'users#create' # 新規登録処理
  
  # generate controller Home index で自動生成されたルートがあれば、必要に応じて削除または残す
  # get 'home/index' 
end