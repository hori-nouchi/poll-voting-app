# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# controllers ディレクトリ内の Stimulus コントローラーを全部登録
pin_all_from "app/javascript/controllers", under: "controllers"

# nested_form_controller.js を個別に使う場合も pin
pin "nested_form_controller", to: "controllers/nested_form_controller.js"
