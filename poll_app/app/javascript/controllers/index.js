// app/javascript/controllers/index.js

import { application } from "./application"
// Railsが提供するStimulusローディングヘルパーを使用
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// controllersフォルダ内のすべてのコントローラーを読み込み、アプリケーションに登録します
eagerLoadControllersFrom("controllers", application)