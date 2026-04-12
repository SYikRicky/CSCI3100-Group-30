import { Controller } from "@hotwired/stimulus"

// Manages the collapsible right-side sidebar on the league show page.
// Each tab button toggles its corresponding panel (accordion — only one open at a time).
// Targets:
//   panel — the content panels (one per tab, in DOM order matching tabs)
export default class extends Controller {
  static targets = ["panel"]

  toggle({ params: { index } }) {
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        const isOpen = panel.dataset.open === "true"
        panel.style.width = isOpen ? "0" : "280px"
        panel.dataset.open = isOpen ? "false" : "true"
      } else {
        panel.style.width = "0"
        panel.dataset.open = "false"
      }
    })
  }
}
