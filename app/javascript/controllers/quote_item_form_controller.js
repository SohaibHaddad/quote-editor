import { Controller } from "@hotwired/stimulus"

const euroFormatter = new Intl.NumberFormat("fr-FR", {
  style: "currency",
  currency: "EUR"
})

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "taxRate", "totalHt", "totalTtc"]

  connect() {
    this.update()
  }

  update() {
    const quantity = this.numberValue(this.quantityTarget.value)
    const unitPrice = this.numberValue(this.unitPriceTarget.value)
    const taxRate = this.numberValue(this.taxRateTarget.value)

    if (quantity === null || unitPrice === null || taxRate === null) {
      this.totalHtTarget.textContent = "Total HT"
      this.totalTtcTarget.textContent = "Total TTC"
      return
    }

    const totalHt = quantity * unitPrice
    const totalTtc = totalHt * (1 + taxRate / 100)

    this.totalHtTarget.textContent = euroFormatter.format(totalHt)
    this.totalTtcTarget.textContent = euroFormatter.format(totalTtc)
  }

  numberValue(value) {
    const normalizedValue = value.toString().trim().replace(",", ".")

    if (normalizedValue === "") {
      return null
    }

    const parsedValue = Number.parseFloat(normalizedValue)
    return Number.isNaN(parsedValue) ? null : parsedValue
  }
}
