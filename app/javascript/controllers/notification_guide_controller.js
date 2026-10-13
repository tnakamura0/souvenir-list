import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (localStorage.getItem("notificationGuideDismissed") === "true") {
      this.element.remove()
    }
  }

  close() {
    localStorage.setItem("notificationGuideDismissed", "true")
    this.element.remove()
  }
}
