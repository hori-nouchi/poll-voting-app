import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラー: ネストされたフォームの動的な追加・削除を処理します。
export default class extends Controller {
  // v2では、元のターゲット名である "template" に戻して使用します。
  static targets = ["container", "template"]; 

  connect() {
    // 接続メッセージを v2 バージョンに変更
    console.log("SUCCESS: nested-form v2 Controller connected! (Target: template)");
  }
  
  // 選択肢を追加する (data-action="click->nested-form-v2#add" で呼び出される)
  add(event) {
    event.preventDefault();
    console.log("Action: v2 add button clicked."); 

    // 1. テンプレートHTMLを取得
    const templateContent = this.templateTarget.innerHTML;

    // 2. プレースホルダー "NEW_RECORD" をユニークなIDに置き換える
    const uniqueId = new Date().getTime() + Math.floor(Math.random() * 1000000);
    const newHtml = templateContent.replace(/NEW_RECORD/g, uniqueId);
    
    // 3. テンプレートをコンテナの末尾に追加
    this.containerTarget.insertAdjacentHTML("beforeend", newHtml);
  }

  // 選択肢を削除する (data-action="nested-form-v2#remove" で呼び出される)
  remove(event) {
    event.preventDefault();
    console.log("Action: v2 remove button clicked."); 

    const item = event.target.closest(".nested-fields");
    const destroyField = item.querySelector('input[name*="_destroy"]');
    
    if (destroyField) {
      destroyField.value = '1';
      item.style.display = 'none'; 
    } 
    else {
      item.remove();
    }
  }
}