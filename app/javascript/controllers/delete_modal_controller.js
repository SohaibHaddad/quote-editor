import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "message"]
  static values = {
    defaultMessage: String
  }

  open(event) {
    const { deleteUrl, deleteMessage } = event.currentTarget.dataset

    this.formTarget.action = deleteUrl
    this.messageTarget.textContent = deleteMessage || this.defaultMessageValue

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
}
