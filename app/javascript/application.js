// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import * as bootstrap from "bootstrap"
import "trix"
import "@rails/actiontext"

// Only allow image attachments in Trix editor
document.addEventListener("trix-file-accept", (event) => {
  const acceptedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
  if (!acceptedTypes.includes(event.file.type)) {
    event.preventDefault()
    alert("Only image files (JPEG, PNG, GIF, WEBP) are allowed.")
  }
})
