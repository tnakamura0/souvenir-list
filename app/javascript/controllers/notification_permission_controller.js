import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "default",
    "granted",
    "denied",
    "unsupported",
    "registering",
    "failed"
  ]

  static values = {
    vapidPublicKey: String
  }

  connect() {
    this.updateUI()

    if (this.isSupported() && Notification.permission === "granted") {
      this.registerPushSubscription()
    }
  }

  async request() {
    if (!this.isSupported()) return
    if (Notification.permission !== "default") return

    try {
      const permission = await Notification.requestPermission()

      this.updateUI()

      if (permission === "granted") {
        await this.registerPushSubscription()
      }
    } catch (error) {
      console.error("通知の許可取得に失敗しました", error)

      this.hideAll()
      this.failedTarget.hidden = false
    }
  }

  async registerPushSubscription() {
    if (Notification.permission !== "granted") return
    if (this.isRegistering) return

    this.isRegistering = true

    this.hideAll()
    this.registeringTarget.hidden = false

    try {
      const registration = await navigator.serviceWorker.ready

      let subscription = await registration.pushManager.getSubscription()

      if (!subscription) {
        subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
        })
      }

      await this.saveSubscription(subscription)

      this.hideAll()
      this.grantedTarget.hidden = false
    } catch (error) {
      console.error("Push Subscriptionの登録に失敗しました", error)

      this.hideAll()
      this.failedTarget.hidden = false
    } finally {
      this.isRegistering = false
    }
  }

  async saveSubscription(subscription) {
    const subscriptionData = subscription.toJSON()

    const response = await fetch("/push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        push_subscription: {
          endpoint: subscriptionData.endpoint,
          p256dh: subscriptionData.keys.p256dh,
          auth: subscriptionData.keys.auth
        }
      })
    })

    if (!response.ok) {
      throw new Error("Push Subscriptionの保存に失敗しました")
    }
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/-/g, "+")
      .replace(/_/g, "/")

    const rawData = atob(base64)

    return Uint8Array.from(rawData, char => char.charCodeAt(0))
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
    this.registeringTarget.hidden = true
    this.failedTarget.hidden = true
  }

  isSupported() {
    return "Notification" in window &&
           "serviceWorker" in navigator &&
           "PushManager" in window
  }
}
