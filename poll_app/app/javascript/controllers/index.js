// Stimulusコントローラーのコア設定をインポート
import { application } from "./application"

// =========================================================================
// 🚨 esbuildのワイルドカードエラー回避のため、手動インポートに切り替えます 🚨
// =========================================================================

// HTML側 (_form.html.erb) で "nested-form" が使われているため、
// 存在する nested_form_controller をその名前で登録します。

import NestedFormV2Controller from "./nested_form_controller" 
application.register("nested-form", NestedFormV2Controller)


// 登録が必要な他のコントローラがあればここに追加します
// 例:
// import PollController from "./poll_controller"
// application.register("poll", PollController)


console.log("Stimulus controllers manually loaded and registered.")