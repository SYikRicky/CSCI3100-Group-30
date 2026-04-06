import { Controller } from "@hotwired/stimulus"

// Manages the floating friend panel in the bottom-right corner.
// Target:
//   panel — the friend list card (initially display:none)
export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    const panel = this.panelTarget
    panel.style.display = panel.style.display === "none" ? "block" : "none"
  }
}
