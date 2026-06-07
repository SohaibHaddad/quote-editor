import { afterEach, describe, expect, it } from "vitest"
import { Application } from "@hotwired/stimulus"
import QuoteItemGuardController from "../../app/javascript/controllers/quote_item_guard_controller.js"

function mount(html) {
  document.body.innerHTML = html

  const application = Application.start()
  application.register("quote-item-guard", QuoteItemGuardController)

  return application
}

describe("QuoteItemGuardController", () => {
  afterEach(() => {
    document.body.className = ""
    document.body.innerHTML = ""
  })

  it("blocks the action and opens the modal when a quote item form row is present", async () => {
    const application = mount(`
      <div data-controller="quote-item-guard" data-quote-item-guard-form-row-selector-value="[data-quote-item-form-row='true']" data-quote-item-guard-message-value="Save first.">
        <a id="trigger" data-action="click->quote-item-guard#blockIfUnsaved"></a>
        <div data-quote-item-form-row="true"></div>
        <div data-quote-item-guard-target="modal" class="hidden">
          <p data-quote-item-guard-target="message"></p>
        </div>
      </div>
    `)

    await Promise.resolve()

    const event = {
      preventDefaultCalled: false,
      stopImmediatePropagationCalled: false,
      preventDefault() { this.preventDefaultCalled = true },
      stopImmediatePropagation() { this.stopImmediatePropagationCalled = true }
    }
    const controllerElement = document.querySelector('[data-controller="quote-item-guard"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "quote-item-guard")
    controller.blockIfUnsaved(event)

    expect(event.preventDefaultCalled).toBe(true)
    expect(event.stopImmediatePropagationCalled).toBe(true)
    expect(document.querySelector('[data-quote-item-guard-target="modal"]').classList.contains("hidden")).toBe(false)
    expect(document.querySelector('[data-quote-item-guard-target="message"]').textContent).toBe("Save first.")
    expect(document.body.classList.contains("overflow-hidden")).toBe(true)

    application.stop()
  })

  it("allows the action when no quote item form row is present", async () => {
    const application = mount(`
      <div data-controller="quote-item-guard" data-quote-item-guard-form-row-selector-value="[data-quote-item-form-row='true']" data-quote-item-guard-message-value="Save first.">
        <a id="trigger" data-action="click->quote-item-guard#blockIfUnsaved"></a>
        <div data-quote-item-guard-target="modal" class="hidden">
          <p data-quote-item-guard-target="message"></p>
        </div>
      </div>
    `)

    await Promise.resolve()

    const event = { preventDefaultCalled: false, preventDefault() { this.preventDefaultCalled = true } }
    const controllerElement = document.querySelector('[data-controller="quote-item-guard"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "quote-item-guard")
    controller.blockIfUnsaved(event)

    expect(event.preventDefaultCalled).toBe(false)
    expect(document.querySelector('[data-quote-item-guard-target="modal"]').classList.contains("hidden")).toBe(true)

    application.stop()
  })

  it("closes the modal", async () => {
    const application = mount(`
      <div data-controller="quote-item-guard" data-quote-item-guard-form-row-selector-value="[data-quote-item-form-row='true']" data-quote-item-guard-message-value="Save first.">
        <div data-quote-item-guard-target="modal">
          <p data-quote-item-guard-target="message"></p>
        </div>
      </div>
    `)

    await Promise.resolve()

    document.body.classList.add("overflow-hidden")
    const controllerElement = document.querySelector('[data-controller="quote-item-guard"]')
    const controller = application.getControllerForElementAndIdentifier(controllerElement, "quote-item-guard")
    controller.close()

    expect(document.querySelector('[data-quote-item-guard-target="modal"]').classList.contains("hidden")).toBe(true)
    expect(document.body.classList.contains("overflow-hidden")).toBe(false)

    application.stop()
  })
})
