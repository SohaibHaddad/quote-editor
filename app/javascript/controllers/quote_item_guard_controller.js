import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "message"]
  static values = {
    formRowSelector: String,
    message: String
  }

  blockIfUnsaved(event) {
    if (!this.hasOpenFormRows()) return

    event.preventDefault()
    event.stopImmediatePropagation?.()
    this.messageTarget.textContent = this.messageValue
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeBackground(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  hasOpenFormRows() {
    return this.element.querySelector(this.formRowSelectorValue) !== null
  }
}
