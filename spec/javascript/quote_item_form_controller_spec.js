import { afterEach, describe, expect, it } from "vitest"
import { Application } from "@hotwired/stimulus"
import QuoteItemFormController from "../../app/javascript/controllers/quote_item_form_controller.js"

function mount(html) {
  document.body.innerHTML = html

  const application = Application.start()
  application.register("quote-item-form", QuoteItemFormController)

  return application
}

describe("QuoteItemFormController", () => {
  afterEach(() => {
    document.body.innerHTML = ""
  })

  it("shows placeholder labels when values are incomplete", async () => {
    const application = mount(`
      <div data-controller="quote-item-form" data-quote-item-form-total-ht-placeholder-value="Total HT" data-quote-item-form-total-ttc-placeholder-value="Total TTC">
        <input data-quote-item-form-target="quantity" value="">
        <input data-quote-item-form-target="unitPrice" value="12.34">
        <select data-quote-item-form-target="taxRate"><option value="20" selected>20%</option></select>
        <div data-quote-item-form-target="totalHt"></div>
        <div data-quote-item-form-target="totalTtc"></div>
      </div>
    `)

    await Promise.resolve()

    expect(document.querySelector('[data-quote-item-form-target="totalHt"]').textContent).toBe("Total HT")
    expect(document.querySelector('[data-quote-item-form-target="totalTtc"]').textContent).toBe("Total TTC")

    application.stop()
  })

  it("computes live totals from decimal amount input", async () => {
    const application = mount(`
      <div data-controller="quote-item-form" data-quote-item-form-total-ht-placeholder-value="Total HT" data-quote-item-form-total-ttc-placeholder-value="Total TTC">
        <input data-quote-item-form-target="quantity" value="2">
        <input data-quote-item-form-target="unitPrice" value="12.50">
        <select data-quote-item-form-target="taxRate"><option value="20" selected>20%</option></select>
        <div data-quote-item-form-target="totalHt"></div>
        <div data-quote-item-form-target="totalTtc"></div>
      </div>
    `)

    await Promise.resolve()

    expect(document.querySelector('[data-quote-item-form-target="totalHt"]').textContent).toBe("25,00 €")
    expect(document.querySelector('[data-quote-item-form-target="totalTtc"]').textContent).toBe("30,00 €")

    application.stop()
  })

  it("accepts comma decimals when updating", async () => {
    const application = mount(`
      <div data-controller="quote-item-form" data-quote-item-form-total-ht-placeholder-value="Total HT" data-quote-item-form-total-ttc-placeholder-value="Total TTC">
        <input data-quote-item-form-target="quantity" value="3">
        <input data-quote-item-form-target="unitPrice" value="10,10">
        <select data-quote-item-form-target="taxRate"><option value="10" selected>10%</option></select>
        <div data-quote-item-form-target="totalHt"></div>
        <div data-quote-item-form-target="totalTtc"></div>
      </div>
    `)

    await Promise.resolve()

    expect(document.querySelector('[data-quote-item-form-target="totalHt"]').textContent).toBe("30,30 €")
    expect(document.querySelector('[data-quote-item-form-target="totalTtc"]').textContent).toBe("33,33 €")

    application.stop()
  })
})
