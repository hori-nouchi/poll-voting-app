# config/importmap.rb

# 標準で生成されるピン設定
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "controllers" # Stimulusコントローラーのエントリーポイント

# 🚨 必須: controllers ディレクトリ全体をピン留めして自動ロードを有効にする
# この行は importmap:install で生成されないため、手動で追加します。
pin_all_from "app/javascript/controllers", under: "controllers" 

# vendor/javascript へのピンは、この環境では通常不要です。