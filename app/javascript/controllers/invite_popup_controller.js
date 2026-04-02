import { Controller } from "@hotwired/stimulus"

// Manages the friend-invite popup on the league creation form.
// Targets:
//   popup — the modal overlay (initially display:none)
//   input — the invitee text field on the main form
export default class extends Controller {
  static targets = ["popup", "input"]

  open(event) {
    event.preventDefault()
    this.popupTarget.style.display = "flex"
  }

  close(event) {
    event.preventDefault()
    this.popupTarget.style.display = "none"
  }

  // Called when a friend row is clicked — copies their identifier and closes.
  select(event) {
    event.preventDefault()
    this.inputTarget.value = event.currentTarget.dataset.value
    this.popupTarget.style.display = "none"
  }

  // Close when clicking the dark backdrop (not the inner card).
  backdropClose(event) {
    if (event.target === this.popupTarget) {
      this.popupTarget.style.display = "none"
    }
  }
}
