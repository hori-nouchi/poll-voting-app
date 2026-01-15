import { Controller } from "@hotwired/stimulus";

/**
 * Stimulus Controller: Rails Nested Attributes
 * Turbo環境下での422エラーを防ぎ、データの整合性を保ちます
 */
export default class extends Controller {
  static targets = ["container", "template", "count"];

  connect() {
    this.updateCount();
  }

  /**
   * 新しいフィールドをテンプレートから追加
   */
  add(event) {
    event.preventDefault();

    const templateContent = this.templateTarget.innerHTML;
    // ユニークなIDを生成してRailsのプレースホルダーを置換
    const uniqueId = new Date().getTime() + Math.floor(Math.random() * 1000);
    const newHtml = templateContent.replace(/NEW_RECORD/g, uniqueId);

    this.containerTarget.insertAdjacentHTML("beforeend", newHtml);
    this.updateCount();
  }

  /**
   * フィールドを削除
   */
  remove(event) {
    event.preventDefault();

    const item = event.target.closest(".nested-fields");
    if (!item) return;

    // _destroy フィールド（hidden）を探す
    const destroyField = item.querySelector('input[name*="_destroy"]');

    if (destroyField) {
      // ケース1: DBに既に存在するデータ
      // Railsの accepts_nested_attributes_for で削除対象として認識させる
      destroyField.value = "1";
      item.style.display = "none";
      item.classList.add("hidden-nested-item");

      // 送信時にHTML5バリデーションに引っかからないよう、すべての required を解除
      const inputs = item.querySelectorAll("input, textarea, select");
      inputs.forEach(input => {
        input.removeAttribute("required");
        // サーバー側のバリデーションエラーを避けるため、値もクリアしておくとより安全です
        if (input !== destroyField && input.type !== 'hidden') {
          input.value = ""; 
        }
      });
    } else {
      // ケース2: まだ保存されていない新規項目
      // サーバーに送る必要がないため、DOMから完全に削除
      item.remove();
    }

    this.updateCount();
  }

  /**
   * 現在の有効な項目数を更新（画面表示用）
   */
  updateCount() {
    if (!this.hasCountTarget) return;
    const visibleItems = this.containerTarget.querySelectorAll(".nested-fields:not(.hidden-nested-item)");
    this.countTarget.textContent = visibleItems.length;
  }
}