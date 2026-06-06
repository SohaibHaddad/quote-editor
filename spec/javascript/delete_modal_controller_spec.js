import { afterEach, describe, expect, it } from "vitest"
import { Application } from "@hotwired/stimulus"
import DeleteModalController from "../../app/javascript/controllers/delete_modal_controller.js"

function mount(html) {
  document.body.innerHTML = html

  const application = Application.start()
  application.register("delete-modal", DeleteModalController)

  return application
}

describe("DeleteModalController", () => {
  afterEach(() => {
    document.body.className = ""
    document.body.innerHTML = ""
  })

  it("opens the modal and injects the delete metadata", async () => {
    const application = mount(`
      <div data-controller="delete-modal">
        <button
          id="trigger"
          data-action="delete-modal#open"
          data-delete-url="/quotes/1"
          data-delete-message="This quote will be removed.">
        </button>
        <div data-delete-modal-target="modal" class="hidden">
          <p data-delete-modal-target="message"></p>
          <form data-delete-modal-target="form"></form>
        </div>
      </div>
    `)

    await Promise.resolve()
    const controllerElement = document.querySelector('[data-controller="delete-modal"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "delete-modal")
    controller.open({ currentTarget: document.getElementById("trigger") })

    expect(document.querySelector('[data-delete-modal-target="form"]').action).toBe("http://localhost:3000/quotes/1")
    expect(document.querySelector('[data-delete-modal-target="message"]').textContent).toBe("This quote will be removed.")
    expect(document.querySelector('[data-delete-modal-target="modal"]').classList.contains("hidden")).toBe(false)
    expect(document.body.classList.contains("overflow-hidden")).toBe(true)

    application.stop()
  })

  it("closes the modal", async () => {
    const application = mount(`
      <div data-controller="delete-modal">
        <button
          id="trigger"
          data-action="delete-modal#open"
          data-delete-url="/quotes/1">
        </button>
        <div data-delete-modal-target="modal" class="hidden">
          <p data-delete-modal-target="message"></p>
          <form data-delete-modal-target="form"></form>
        </div>
      </div>
    `)

    await Promise.resolve()

    const controllerElement = document.querySelector('[data-controller="delete-modal"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "delete-modal")
    controller.open({ currentTarget: document.getElementById("trigger") })
    controller.close()

    expect(document.querySelector('[data-delete-modal-target="modal"]').classList.contains("hidden")).toBe(true)
    expect(document.body.classList.contains("overflow-hidden")).toBe(false)

    application.stop()
  })

  it("closes only when the backdrop is clicked", async () => {
    const application = mount(`
      <div data-controller="delete-modal">
        <button
          id="trigger"
          data-action="delete-modal#open"
          data-delete-url="/quotes/1">
        </button>
        <div id="modal" data-delete-modal-target="modal" class="hidden">
          <div id="content">
            <p data-delete-modal-target="message"></p>
            <form data-delete-modal-target="form"></form>
          </div>
        </div>
      </div>
    `)

    await Promise.resolve()

    const controllerElement = document.querySelector('[data-controller="delete-modal"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "delete-modal")
    controller.open({ currentTarget: document.getElementById("trigger") })

    controller.closeBackground({ target: document.getElementById("content") })
    expect(document.querySelector('[data-delete-modal-target="modal"]').classList.contains("hidden")).toBe(false)

    controller.closeBackground({ target: document.getElementById("modal") })
    expect(document.querySelector('[data-delete-modal-target="modal"]').classList.contains("hidden")).toBe(true)

    application.stop()
  })
})
