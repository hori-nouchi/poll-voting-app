import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラー: ネストされたフォームの動的な追加・削除を処理します。
export default class extends Controller {
  // ターゲット名をHTMLに合わせて修正: "container", "template" および "count" を追加 
  static targets = ["container", "template", "count"]; 

  connect() {
    // 接続確認用ログ (デプロイエラーの原因ではない)
    console.log("SUCCESS: nested-form Controller connected!");
    // 接続時に一度カウントを更新
    this.updateCount();
  }
  
  // 選択肢を追加する (data-action="click->nested-form#add" で呼び出される)
  add(event) {
    event.preventDefault();
    
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

    // 削除対象の親要素 (.nested-fields) を見つける
    const item = event.target.closest(".nested-fields");
    
    if (!item) {
        console.error("Error: Could not find .nested-fields parent for removal.");
        return;
    }
    
    // _destroy hidden fieldを探す
    const destroyField = item.querySelector('input[name*="_destroy"]');
    
    if (destroyField) {
      // 既存レコードの場合、_destroyフィールドをセットし、DOMからは非表示にする
      destroyField.value = '1';
      item.style.display = 'none'; 
    } 
    else {
      // 新規レコードの場合、DOMから完全に削除する
      item.remove();
    }
    
    // カウントを更新
    this.updateCount();
  }

  // 現在の選択肢の数を数えて表示を更新するヘルパーメソッド
  updateCount() {
    // .nested-fields クラスを持ち、かつ非表示(display:none)や_destroy='1'でない要素を数える
    const visibleChoices = Array.from(this.containerTarget.querySelectorAll('.nested-fields'))
      .filter(item => {
        // スタイルで非表示になっている要素（削除済み既存レコード）はカウントしない
        if (item.style.display === 'none') {
            return false;
        }
        
        const destroyField = item.querySelector('input[name*="_destroy"]');
        // _destroyがない（新規レコード）または _destroy が '0' であれば可視とみなす
        return !destroyField || destroyField.value !== '1';
      });

    this.countTarget.textContent = visibleChoices.length;
    // console.log(`Count updated: ${visibleChoices.length}`);
  }
}