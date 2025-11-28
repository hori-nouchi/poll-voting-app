import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラー: ネストされたフォームの動的な追加・削除を処理します。
export default class extends Controller {
  // ターゲット名を 'container' (フィールドを格納する親要素) と 'add_item' (テンプレート) に設定 
  static targets = ["container", "add_item"];

  // 選択肢を追加する (data-action="click->nested-form#add" で呼び出される)
  add(event) {
    event.preventDefault();

    // テンプレートHTMLを取得し、ユニークなタイムスタンプで "NEW_RECORD" を置き換える
    // "NEW_RECORD" は Rails が一時的に使うプレースホルダーです。
    const template = this.add_itemTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    
    // テンプレートをコンテナの末尾に追加
    this.containerTarget.insertAdjacentHTML("beforeend", template);
  }

  // 選択肢を削除する (data-action="nested-form#remove" で呼び出される)
  remove(event) {
    event.preventDefault();

    // 削除ボタンの最も近い親要素 (.nested-fields) を取得
    const item = event.target.closest(".nested-fields");
    
    // 隠しフィールド (_destroy) を探す
    const destroyField = item.querySelector('input[name*="_destroy"]');
    
    // 既存のレコード (データベースに保存済みのもの) の場合
    if (destroyField) {
      // _destroy フィールドの値を '1' に設定し、削除フラグを立てる
      destroyField.value = '1';
      // ユーザーに見せないように要素を非表示にする
      item.style.display = 'none'; 
    } 
    // 新規レコード (まだデータベースに保存されていないもの) の場合
    else {
      // 単にDOMから要素を削除する
      item.remove();
    }
  }
}