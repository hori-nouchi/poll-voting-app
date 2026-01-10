import { Controller } from "@hotwired/stimulus";

/**
 * Stimulus Controller: Rails Nested Attributes
 * 削除された項目のバリデーションを完全に無効化します
 */
export default class extends Controller {
  static targets = ["container", "template", "count"];

  connect() {
    this.updateCount();
    // フォーム要素を見つけて、送信イベントを監視
    const form = this.element.closest("form");
    if (form) {
      form.addEventListener("submit", this.handleSubmit.bind(this));
    }
  }

  /**
   * 送信時の処理
   */
  handleSubmit(event) {
    // 1. 削除された要素の入力を完全に無効化し、name属性を消去
    const hiddenItems = this.containerTarget.querySelectorAll(".hidden-nested-item");
    hiddenItems.forEach((item) => {
      const inputs = item.querySelectorAll("input, textarea, select");
      inputs.forEach((input) => {
        // _destroy フィールドだけは残す必要がある
        if (input.name.includes("_destroy")) {
          input.value = "1";
          input.disabled = false;
        } else {
          // それ以外は送信対象から外し、バリデーションも無効化
          input.removeAttribute("required");
          input.disabled = true;
          input.removeAttribute("name"); // サーバーに送らない
        }
      });
    });

    // 2. ブラウザのHTML5バリデーションで止まるのを防ぐ
    // (既に削除された項目にhiddenで残っているrequiredが反応するのを防ぐ)
    this.element.closest("form").setAttribute("novalidate", "true");
  }

  /**
   * 新しいフィールドを追加
   */
  add(event) {
    event.preventDefault();

    const templateContent = this.templateTarget.innerHTML;
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

    // 削除ボタンが押された要素をマーク
    item.classList.add("hidden-nested-item");
    item.style.display = "none";

    const destroyField = item.querySelector('input[name*="_destroy"]');

    if (destroyField) {
      // 既存データの場合: _destroyを1にして残す
      destroyField.value = "1";
      // 他の入力のrequiredを即座に外す（送信を待たずに）
      const inputs = item.querySelectorAll("input, textarea, select");
      inputs.forEach(input => {
        if (!input.name.includes("_destroy")) {
          input.removeAttribute("required");
        }
      });
    } else {
      // 新規追加データの場合: DOMから消してOK
      item.remove();
    }

    this.updateCount();
  }

  updateCount() {
    if (!this.hasCountTarget) return;
    const visibleItems = this.containerTarget.querySelectorAll(".nested-fields:not(.hidden-nested-item)");
    this.countTarget.textContent = visibleItems.length;
  }
}