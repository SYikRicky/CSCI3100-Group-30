import { Controller } from "@hotwired/stimulus"

// Manages the multi-invitee tags input + friend-picker popup on the league form.
// Targets:
//   popup    — the modal overlay (initially display:none)
//   input    — the visible text field for typing an identifier
//   tags     — the chip container showing added invitees
//   rawField — hidden <input> whose value is comma-separated identifiers (submitted with form)
export default class extends Controller {
  static targets = ["popup", "input", "tags", "rawField"]

  // ── Popup open / close ──────────────────────────────────────────────────

  open(event) {
    event.preventDefault()
    this.popupTarget.style.display = "flex"
  }

  close(event) {
    event.preventDefault()
    this.popupTarget.style.display = "none"
  }

  backdropClose(event) {
    if (event.target === this.popupTarget) {
      this.popupTarget.style.display = "none"
    }
  }

  // ── Tag management ──────────────────────────────────────────────────────

  // Called by the "Add" button.
  addTag(event) {
    event.preventDefault()
    const value = this.inputTarget.value.trim()
    if (!value) return
    this._addTag(value)
    this.inputTarget.value = ""
  }

  // Called when a friend row in the popup is clicked.
  select(event) {
    event.preventDefault()
    this._addTag(event.currentTarget.dataset.value)
    this.popupTarget.style.display = "none"
  }

  // Called by the × button on a chip.
  removeTag(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    this.tagsTarget.querySelector(`[data-chip-value="${CSS.escape(value)}"]`)?.remove()
    this._syncRawField()
  }

  // ── Private ─────────────────────────────────────────────────────────────

  _addTag(value) {
    const existing = this._currentValues()
    if (existing.includes(value)) return

    // Visual chip
    const chip = document.createElement("div")
    chip.dataset.chipValue = value
    chip.style.cssText = [
      "display:inline-flex", "align-items:center", "gap:0.3rem",
      "background:#ede9fe", "color:#4f46e5", "border-radius:4px",
      "padding:0.2rem 0.45rem", "font-size:0.8rem"
    ].join(";")

    const label = document.createElement("span")
    label.textContent = value
    chip.appendChild(label)

    const btn = document.createElement("button")
    btn.type = "button"
    btn.dataset.action = "invite-popup#removeTag"
    btn.dataset.value  = value
    btn.innerHTML      = "&times;"
    btn.style.cssText  = "background:none;border:none;cursor:pointer;color:#6d28d9;font-size:1rem;line-height:1;padding:0"
    chip.appendChild(btn)

    this.tagsTarget.appendChild(chip)
    this._syncRawField()
  }

  _currentValues() {
    return Array.from(this.tagsTarget.querySelectorAll("[data-chip-value]"))
      .map(chip => chip.dataset.chipValue)
  }

  // Keeps the hidden CSV field in sync so the form submits all identifiers.
  _syncRawField() {
    this.rawFieldTarget.value = this._currentValues().join(",")
  }
}
