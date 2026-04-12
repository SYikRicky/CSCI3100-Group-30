import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Manages the mailbox notification dropdown in the navigation bar.
// Subscribes to NotificationChannel for real-time updates.
export default class extends Controller {
  static targets = ["dropdown", "badge", "list"]
  static values  = { markReadUrl: String }

  connect() {
    this._handleOutsideClick = this._handleOutsideClick.bind(this)
    document.addEventListener("click", this._handleOutsideClick)

    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create("NotificationChannel", {
      received: (data) => this._onReceived(data)
    })
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick)
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
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

  _onReceived(data) {
    if (data.type === "notification") {
      this._showBadge()
      this._prependNotification(data)
    }
    if (data.type === "new_message") {
      // Skip badge update if user is actively reading this sender's conversation
      const chatWidget = document.querySelector("[data-controller='chat-widget']")
      const activeFriendId = chatWidget?.dataset.activeFriendId
      if (activeFriendId && String(data.sender_id) === activeFriendId) return

      this._updateChatBadge(data.unread_count)
    }
  }

  _showBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.style.display = "block"
    } else {
      // Badge was removed after mark-as-read; re-create it
      const btn = this.element.querySelector("[data-testid='mailbox-btn']")
      if (btn) {
        const dot = document.createElement("span")
        dot.setAttribute("data-mailbox-target", "badge")
        dot.style.cssText = "position: absolute; top: 2px; right: 2px; width: 7px; height: 7px; background: #F6465D; border-radius: 50%; display: block;"
        btn.appendChild(dot)
      }
    }
  }

  _prependNotification(data) {
    if (!this.hasListTarget) return
    const empty = this.listTarget.querySelector("[data-empty]")
    if (empty) empty.remove()

    const item = document.createElement("div")
    item.style.cssText = "padding: 0.6rem 0; border-bottom: 1px solid rgba(255,255,255,0.06);"
    item.innerHTML = `
      <p style="color: #EAECEF; font-size: 0.82rem; font-weight: 600; margin: 0 0 0.2rem;">
        ${this._esc(data.title)}
      </p>
      <p style="color: #929AA5; font-size: 0.78rem; margin: 0;">${this._esc(data.body)}</p>
    `
    this.listTarget.prepend(item)
  }

  _updateChatBadge(unreadCount) {
    // Update the chat widget badge from here since we share the same cable channel
    const badge = document.querySelector("[data-chat-widget-target='badge']")
    const badgeCount = document.querySelector("[data-chat-widget-target='badgeCount']")
    if (badge) {
      badge.style.display = unreadCount > 0 ? "flex" : "none"
    }
    if (badgeCount) {
      badgeCount.textContent = unreadCount > 0 ? unreadCount : ""
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

  _esc(str) {
    const d = document.createElement("div")
    d.textContent = str
    return d.innerHTML
  }
}
