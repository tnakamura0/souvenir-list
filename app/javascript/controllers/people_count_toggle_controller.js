import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="people-count-toggle"
export default class extends Controller {
  static targets = ["field", "input", "groupRadio"]

  connect() {
    this.updatePeopleCountField()
  }

  toggle() {
    this.updatePeopleCountField()
  }

  updatePeopleCountField() {
    if (this.groupRadioTarget.checked) {
      this.fieldTarget.classList.remove("hidden")
      this.inputTarget.disabled = false
    } else {
      this.fieldTarget.classList.add("hidden")
      this.inputTarget.disabled = true
    }
  }
}
