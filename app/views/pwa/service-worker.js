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
