# Importmapで必要なモジュールを定義します。

# Hotwire Turbo と Stimulus の基本ライブラリ
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"

# 🚨 【修正】application.js を廃止し、すべてのコントローラーをインライン化したため、これらは不要です 🚨
# pin "nested_form_controller", to: "controllers/nested_form_controller.js"