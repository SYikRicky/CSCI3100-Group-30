import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["panel", "badge", "badgeCount",
                     "friendList", "chatView", "chatHeader",
                     "messageList", "messageInput"]
  static values  = {
    friendsUrl: String,
    conversationUrl: String,
    markReadUrl: String,
    sendUrl: String,
    currentUserId: Number
  }

  connect() {
    this.selectedFriendId = null
    this.consumer = createConsumer()
    this.subscription = null
  }

  disconnect() {
    this._unsubscribe()
  }

  toggle() {
    const open = this.panelTarget.style.display === "none"
    this.panelTarget.style.display = open ? "flex" : "none"
    if (open) this._loadFriends()
  }

  back() {
    this._unsubscribe()
    this.selectedFriendId = null
    this.chatViewTarget.style.display = "none"
    this.friendListTarget.style.display = "block"
    this._loadFriends()
  }

  send(event) {
    event.preventDefault()
    const content = this.messageInputTarget.value.trim()
    if (!content || !this.selectedFriendId) return

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    fetch(this.sendUrlValue.replace("__FRIEND_ID__", this.selectedFriendId), {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: `message[content]=${encodeURIComponent(content)}`
    })
    this.messageInputTarget.value = ""
  }

  selectFriend(event) {
    const friendId = event.currentTarget.dataset.friendId
    const friendName = event.currentTarget.dataset.friendName
    this.selectedFriendId = friendId

    this.chatHeaderTarget.textContent = friendName
    this.friendListTarget.style.display = "none"
    this.chatViewTarget.style.display = "flex"
    this.messageListTarget.innerHTML = ""

    this._loadConversation(friendId)
    this._markRead(friendId)
  }

  // Private

  _loadFriends() {
    fetch(this.friendsUrlValue, { headers: { "Accept": "application/json" } })
      .then(r => r.json())
      .then(friends => {
        let totalUnread = 0
        this.friendListTarget.innerHTML = friends.length
          ? friends.map(f => {
              totalUnread += f.unread_count
              return `<div data-action="click->chat-widget#selectFriend"
                   data-friend-id="${f.id}" data-friend-name="${this._esc(f.display_name)}"
                   style="padding: 0.5rem 0.6rem; cursor: pointer; border-radius: 6px;
                          transition: background 0.15s; display: flex; justify-content: space-between; align-items: center;"
                   onmouseover="this.style.background='rgba(255,255,255,0.06)'"
                   onmouseout="this.style.background='transparent'">
                <div>
                  <span style="color: #EAECEF; font-weight: 600; font-size: 0.82rem;">${this._esc(f.display_name)}</span>
                  <span style="display: block; color: #929AA5; font-size: 0.7rem;">${this._esc(f.email)}</span>
                </div>
                ${f.unread_count > 0
                  ? `<span style="background: #F6465D; color: #fff; font-size: 0.65rem; font-weight: 700;
                            min-width: 18px; height: 18px; border-radius: 9px; display: flex;
                            align-items: center; justify-content: center; padding: 0 5px;">${f.unread_count}</span>`
                  : ""}
              </div>`
            }).join("")
          : '<p style="color: #929AA5; font-size: 0.82rem; padding: 0.5rem;">No friends yet.</p>'
        this._updateBadge(totalUnread)
      })
  }

  _loadConversation(friendId) {
    fetch(`${this.conversationUrlValue}?friend_id=${friendId}`, {
      headers: { "Accept": "application/json" }
    })
      .then(r => r.json())
      .then(data => {
        this.messageListTarget.innerHTML = data.messages.map(m => this._renderMsg(m)).join("")
        this._scrollToBottom()
        this._subscribe(data.signed_stream_name)
      })
  }

  _renderMsg(m) {
    return `<div style="padding: 0.35rem 0; font-size: 0.8rem;">
      <span style="color: #14B8A6; font-weight: 600;">${this._esc(m.sender_name)}</span>
      <span style="color: #929AA5; font-size: 0.65rem; margin-left: 0.35rem;">${m.created_at}</span>
      <p style="color: #EAECEF; margin: 0.15rem 0 0; word-break: break-word;">${this._esc(m.content)}</p>
    </div>`
  }

  _subscribe(signedStreamName) {
    this._unsubscribe()
    const target = this.messageListTarget

    this.subscription = this.consumer.subscriptions.create(
      { channel: "Turbo::StreamsChannel", signed_stream_name: signedStreamName },
      {
        received(data) {
          const template = document.createElement("template")
          template.innerHTML = data.trim()
          const turboStream = template.content.firstElementChild
          if (turboStream && turboStream.tagName === "TURBO-STREAM" &&
              turboStream.getAttribute("target") === "chat-widget-messages") {
            const content = turboStream.querySelector("template")?.content
            if (content) {
              target.appendChild(content.cloneNode(true))
              target.scrollTop = target.scrollHeight
            }
          }
        }
      }
    )
  }

  _unsubscribe() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }
  }

  _markRead(friendId) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    fetch(`${this.markReadUrlValue}?friend_id=${friendId}`, {
      method: "PATCH",
      headers: { "X-CSRF-Token": csrfToken, "Accept": "application/json" }
    })
      .then(r => r.json())
      .then(data => this._updateBadge(data.unread_count))
  }

  _scrollToBottom() {
    this.messageListTarget.scrollTop = this.messageListTarget.scrollHeight
  }

  _updateBadge(count) {
    if (this.hasBadgeTarget) {
      this.badgeTarget.style.display = count > 0 ? "flex" : "none"
    }
    if (this.hasBadgeCountTarget) {
      this.badgeCountTarget.textContent = count > 0 ? count : ""
    }
  }

  _esc(str) {
    const d = document.createElement("div")
    d.textContent = str
    return d.innerHTML
  }
}
