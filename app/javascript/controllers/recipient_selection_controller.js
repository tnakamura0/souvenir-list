import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkbox",
    "selectedCount",
    "submit"
  ]

  connect() {
    this.update()
  }

  selectAll() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = true
    })

    this.update()
  }

  update() {
    const selectedCount = this.checkboxTargets.filter(
      (checkbox) => checkbox.checked
    ).length

    this.selectedCountTarget.textContent = selectedCount
    this.submitTarget.disabled = selectedCount === 0
  }
}
