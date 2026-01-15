// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
// ページが読み込まれた時に実行する
document.addEventListener('turbo:load', () => {
  const picker = document.getElementById('diary-color-picker');
  const display = document.getElementById('color-code-display');

  // 要素が見つからない場合は何もしない（エラー防止）
  if (!picker || !display) return;

  // カラーパレットの色が動いた時（inputイベント）に実行
  picker.addEventListener('input', (event) => {
    // 選択された色（例: #ff0000）をテキストとして表示する
    const selectedColor = event.target.value;
    display.textContent = selectedColor.toUpperCase();
    
    // おまけ：文字の色もその色に変えるとかっこいいです
    display.style.color = selectedColor;
  });
});
