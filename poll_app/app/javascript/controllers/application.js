import { Application } from "@hotwired/stimulus"

// Stimulusアプリケーションを初期化
const application = Application.start()

// デバッグ情報を無効化 (本番環境向け)
application.debug = false

// window.Stimulus にグローバルに設定
window.Stimulus = application

export { application }