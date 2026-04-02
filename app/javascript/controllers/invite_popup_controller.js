import { Controller } from "@hotwired/stimulus"

// Manages the friend-invite popup on the league creation form.
// Targets:
//   popup  — the overlay element (hidden by default)
//   input  — the visible text field on the form
export default class extends Controller {
  static targets = ["popup", "input"]

  open(event) {
    event.preventDefault()
    this.popupTarget.classList.remove("hidden")
  }

  close(event) {
    event.preventDefault()
    this.popupTarget.classList.add("hidden")
  }

  // Called when a friend row is clicked — copies their email into the input and closes.
  select(event) {
    event.preventDefault()
    this.inputTarget.value = event.currentTarget.dataset.value
    this.popupTarget.classList.add("hidden")
  }

  // Close popup when clicking the backdrop (the overlay itself, not its children).
  backdropClose(event) {
    if (event.target === this.popupTarget) {
      this.popupTarget.classList.add("hidden")
    }
  }
}
