import { Controller } from "@hotwired/stimulus"

// Manages the mailbox notification dropdown in the navigation bar.
// Targets:
//   dropdown — the notification list card (initially display:none)
export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this._handleOutsideClick = this._handleOutsideClick.bind(this)
    document.addEventListener("click", this._handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    const dropdown = this.dropdownTarget
    dropdown.style.display = dropdown.style.display === "none" ? "block" : "none"
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.style.display = "none"
    }
  }
}
