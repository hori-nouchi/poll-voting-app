import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Stimulus Application を初期化し、起動します
const application = Application.start()

// controllersフォルダ内のすべてのコントローラーを読み込み、アプリケーションに登録します
eagerLoadControllersFrom("controllers", application)