import { Controller } from "@hotwired/stimulus"

// Manages the mailbox notification dropdown in the navigation bar.
// Targets:
//   dropdown — the notification list card (initially display:none)
//   badge    — the unread indicator dot
export default class extends Controller {
  static targets = ["dropdown", "badge"]
  static values  = { markReadUrl: String }

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
    const isOpening = dropdown.style.display === "none"
    dropdown.style.display = isOpening ? "block" : "none"

    if (isOpening && this.hasBadgeTarget) {
      this._markAsRead()
    }
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.style.display = "none"
    }
  }

  _markAsRead() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    fetch(this.markReadUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      }
    }).then(() => {
      if (this.hasBadgeTarget) {
        this.badgeTarget.remove()
      }
    })
  }
}
