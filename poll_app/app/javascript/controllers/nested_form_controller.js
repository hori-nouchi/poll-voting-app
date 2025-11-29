import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラー: ネストされたフォームの動的な追加・削除を処理します。
export default class extends Controller {
  // ターゲット名をHTMLに合わせて修正: "container", "template" および "count" を追加 
  static targets = ["container", "template", "count"]; 

  connect() {
    // 接続メッセージを v2 バージョンに変更
    console.log("SUCCESS: nested-form Controller connected! (Target: container, template, count)");
    // 接続時に一度カウントを更新
    this.updateCount();
  }
  
  // 選択肢を追加する (data-action="click->nested-form#add" で呼び出される)
  add(event) {
    event.preventDefault();
    console.log("Action: add button clicked."); 

    // 1. テンプレートHTMLを取得
    const templateContent = this.templateTarget.innerHTML;

    // 2. プレースホルダー "NEW_RECORD" をユニークなIDに置き換える
    const uniqueId = new Date().getTime() + Math.floor(Math.random() * 1000000);
    const newHtml = templateContent.replace(/NEW_RECORD/g, uniqueId);
    
    // 3. テンプレートをコンテナの末尾に追加
    this.containerTarget.insertAdjacentHTML("beforeend", newHtml);

    // 4. カウントを更新
    this.updateCount();
  }

  // 選択肢を削除する (data-action="nested-form#remove" で呼び出される)
  remove(event) {
    event.preventDefault();
    console.log("Action: remove button clicked."); 

    const item = event.target.closest(".nested-fields");
    const destroyField = item.querySelector('input[name*="_destroy"]');
    
    if (destroyField) {
      // 既存レコードの場合、_destroyフィールドをセットして非表示にする
      destroyField.value = '1';
      item.style.display = 'none'; 
    } 
    else {
      // 新規レコードの場合、DOMから削除する
      item.remove();
    }
    
    // カウントを更新
    this.updateCount();
  }

  // 現在の選択肢の数を数えて表示を更新するヘルパーメソッド
  updateCount() {
    // .nested-fields クラスを持ち、かつ _destroy フィールドが '1' でない要素を数える
    const visibleChoices = Array.from(this.containerTarget.querySelectorAll('.nested-fields'))
      .filter(item => {
        const destroyField = item.querySelector('input[name*="_destroy"]');
        return !destroyField || destroyField.value !== '1';
      });

    this.countTarget.textContent = visibleChoices.length;
    console.log(`Count updated: ${visibleChoices.length}`);
  }
}