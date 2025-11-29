import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["options"]

  addOption(event) {
    event.preventDefault()
    const option = document.createElement("input")
    option.type = "text"
    option.name = "poll[options][]"
    option.classList.add("form-control", "mb-2")
    this.optionsTarget.appendChild(option)
  }

  removeOption(event) {
    event.preventDefault()
    if (this.optionsTarget.children.length > 1) {
      this.optionsTarget.removeChild(this.optionsTarget.lastElementChild)
    }
  }
}
