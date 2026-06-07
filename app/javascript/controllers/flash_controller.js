import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 3000 }
  }

  connect() {
    this.timeout = window.setTimeout(() => this.dismiss(), this.dismissAfterValue)
  }

  disconnect() {
    if (this.timeout) window.clearTimeout(this.timeout)
    if (this.removeTimeout) window.clearTimeout(this.removeTimeout)
  }

  dismiss() {
    this.element.classList.add("opacity-0")
    this.element.classList.add("transition-opacity")
    this.element.classList.add("duration-300")

    this.removeTimeout = window.setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
