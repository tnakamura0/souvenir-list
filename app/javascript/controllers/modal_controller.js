import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    const name = event.params.dialog

    if (name) {
      const dialog = this.dialogTargets.find((dialog) => dialog.dataset.modalName === name)
      dialog?.showModal()
      return
    }

    this.dialogTarget.showModal()
  }

  close(event) {
    const dialog = event.currentTarget.closest("dialog")

    if (dialog) {
      dialog.close()
      return
    }

    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      event.currentTarget.close()
    }
  }
}
