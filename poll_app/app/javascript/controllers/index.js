// Stimulusアプリケーションのコア設定をインポート
import { application } from "./application.js"

// -------------------------------------------------------------------------
// 🚨 個別のコントローラーを登録 🚨
// -------------------------------------------------------------------------

// Stimulusコントローラーを動的にロードし、アプリケーションに登録します。
// Importmapでは、コントローラーのインポートは手動またはワイルドカードなしで行う必要があります。

// 1. Nested Form Controller をインポート
import NestedFormController from "./nested_form_controller.js" 

// 2. Pollフォームで使用されている data-controller="nested-form" に対応
application.register("nested-form", NestedFormController)


// 登録が必要な他のコントローラがあればここに追加します
// 例:
// import PollController from "./poll_controller.js"
// application.register("poll", PollController)


console.log("Stimulus controllers initialized and registered.")