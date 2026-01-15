// app/javascript/controllers/options_controller.js

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="options"
export default class extends Controller {
  static targets = ["fields", "template", "field"]

  // 選択肢を追加するメソッド
  addField() {
    // テンプレートの内容を取得
    const template = this.templateTarget.innerHTML
    
    // テンプレートをfieldsターゲットの最後に追加
    this.fieldsTarget.insertAdjacentHTML("beforeend", template)
  }

  // 選択肢を削除するメソッド
  removeField(event) {
    // 現在表示されている選択肢の数を確認
    // this.fieldTargetsはdata-options-target="field"を持つ全要素のリスト
    if (this.fieldTargets.length > 2) {
      // クリックされたボタンの親要素 (data-options-target="field"を持つdiv) を取得
      const fieldToRemove = event.target.closest("[data-options-target='field']")
      fieldToRemove.remove()
    } else {
      // 選択肢が2個以下になるのを防ぐ
      alert("選択肢は最低2つ必要です。")
    }
  }
}