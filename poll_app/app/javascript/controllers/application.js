// app/javascript/controllers/application.js

import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Stimulusのデバッグ設定（任意）
application.debug = false
window.Stimulus = application

export { application }