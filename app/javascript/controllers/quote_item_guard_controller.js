import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "message"]
  static values = {
    formRowSelector: String,
    message: String
  }

  blockIfUnsaved(event) {
    if (!this.hasOpenFormRows()) return

    this.openGuardModal(event)
  }

  blockIfUnsavedOrOpenDeleteModal(event) {
    if (this.hasOpenFormRows()) {
      this.openGuardModal(event)
      return
    }

    event.preventDefault()
    const deleteModalElement = document.querySelector("[data-controller~='delete-modal']")
    const deleteModalController = this.application.getControllerForElementAndIdentifier(deleteModalElement, "delete-modal")
    deleteModalController?.open({ currentTarget: event.currentTarget })
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

  openGuardModal(event) {
    event.preventDefault()
    event.stopImmediatePropagation?.()
    this.messageTarget.textContent = this.messageValue
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }
}
