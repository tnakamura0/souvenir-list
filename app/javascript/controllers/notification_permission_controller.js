import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "default",
    "granted",
    "denied",
    "unsupported"
  ]

  connect() {
    this.updateUI()
  }

  async request() {
    if (!this.isSupported()) return
    if (Notification.permission !== "default") return

    await Notification.requestPermission()

    this.updateUI()
  }

  updateUI() {
    this.hideAll()

    if (!this.isSupported()) {
      this.unsupportedTarget.hidden = false
      return
    }

    switch (Notification.permission) {
      case "default":
        this.defaultTarget.hidden = false
        break
      case "granted":
        this.grantedTarget.hidden = false
        break
      case "denied":
        this.deniedTarget.hidden = false
        break
    }
  }

  hideAll() {
    this.defaultTarget.hidden = true
    this.grantedTarget.hidden = true
    this.deniedTarget.hidden = true
    this.unsupportedTarget.hidden = true
  }

  isSupported() {
    return "Notification" in window
  }
}
