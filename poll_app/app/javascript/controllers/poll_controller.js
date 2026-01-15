import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    // 接続確認用（必要なければ削除してOK）
    console.log("Poll form controller connected")
  }

  // 選択肢を追加するアクション
  addChoice(event) {
    event.preventDefault()
    
    // テンプレートから新しいHTMLを作成
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    
    // コンテナの最後に追加
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  // 選択肢を削除するアクション
  removeChoice(event) {
    event.preventDefault()
    
    // 削除ボタンの親要素（選択肢の入力フィールド一式）を取得
    const wrapper = event.target.closest('.choice-field')
    
    // 既存データ（IDがあるもの）の場合は隠して _destroy を 1 にする処理が必要になる場合がありますが、
    // 新規作成時であれば単純に削除して問題ありません
    if (this.containerTarget.querySelectorAll('.choice-field').length > 1) {
      wrapper.remove()
    } else {
      alert("選択肢は最低1つ必要です。")
    }
  }
}