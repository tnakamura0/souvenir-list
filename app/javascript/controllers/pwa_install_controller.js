import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "notification",
    "install",
    "installHelp",
    "installed"
  ]

  connect() {
    this.deferredPrompt = null

    this.handleBeforeInstallPrompt = this.handleBeforeInstallPrompt.bind(this)
    this.handleAppInstalled = this.handleAppInstalled.bind(this)

    window.addEventListener(
      "beforeinstallprompt",
      this.handleBeforeInstallPrompt
    )

    window.addEventListener(
      "appinstalled",
      this.handleAppInstalled
    )

    this.updateUI()
  }

  disconnect() {
    window.removeEventListener(
      "beforeinstallprompt",
      this.handleBeforeInstallPrompt
    )

    window.removeEventListener(
      "appinstalled",
      this.handleAppInstalled
    )
  }

  async install() {
    if (!this.deferredPrompt) return

    await this.deferredPrompt.prompt()

    this.deferredPrompt = null
    this.updateUI()
  }

  handleBeforeInstallPrompt(event) {
    event.preventDefault()

    this.deferredPrompt = event
    this.updateUI()
  }

  handleAppInstalled() {
    this.deferredPrompt = null
    this.hideAll()
    this.installedTarget.hidden = false
  }

  updateUI() {
    this.hideAll()

    if (this.isStandalone()) {
      this.notificationTarget.hidden = false
    } else if (this.deferredPrompt) {
      this.installTarget.hidden = false
    } else {
      this.installHelpTarget.hidden = false
    }
  }

  hideAll() {
    this.notificationTarget.hidden = true
    this.installTarget.hidden = true
    this.installHelpTarget.hidden = true
    this.installedTarget.hidden = true
  }

  isStandalone() {
    return window.matchMedia("(display-mode: standalone)").matches
  }
}
