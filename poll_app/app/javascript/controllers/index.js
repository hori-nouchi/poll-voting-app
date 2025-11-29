import { Application } from "@hotwired/stimulus"

const application = Application.start()

// controllers ディレクトリ内の *_controller.js を全部読み込む
const controllerFiles = import.meta.glob("./**/*_controller.js")

for (const path in controllerFiles) {
  controllerFiles[path]().then((module) => {
    const controllerName = path
      .replace("./", "")
      .replace("_controller.js", "")
      .replace("/", "--") // Rails命名規則に合わせる
    application.register(controllerName, module.default)
  })
}

export { application }
