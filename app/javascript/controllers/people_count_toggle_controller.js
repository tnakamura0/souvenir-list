import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="people-count-toggle"
export default class extends Controller {
  static targets = ["field"]

  toggle(event) {
    if (event.target.value === "group") {
      this.fieldTarget.classList.remove("hidden")
    } else {
      this.fieldTarget.classList.add("hidden")
    }
  }
}
