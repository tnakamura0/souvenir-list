// Add a service worker for processing Web Push notifications:
self.addEventListener("push", (event) => {
  let payload = {}

  try {
    payload = event.data?.json() ?? {}
  } catch (error) {
    console.error("Invalid push payload:", error)
  }

  const title = payload.title || "OmiMemo"

  const options = {
    body: payload.body || "お知らせがあります"
  }

  event.waitUntil(
    self.registration.showNotification(title, options)
  )
})

self.addEventListener("notificationclick", (event) => {
  event.notification.close()

  event.waitUntil((async () => {
    const targetUrl = new URL("/", self.location.origin).href

    const clientList = await clients.matchAll({
      type: "window",
      includeUncontrolled: true
    })

    const existingClient = clientList.find((client) => {
      return new URL(client.url).origin === self.location.origin
    })

    if (existingClient) {
      const navigatedClient = await existingClient.navigate(targetUrl)

      if (navigatedClient) {
        return navigatedClient.focus()
      }
    }

    return clients.openWindow(targetUrl)
  })())
})
