import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "desafio:closed-groups"

// Remembers which groups the user collapsed, so they stay closed across reloads.
export default class extends Controller {
  connect() {
    if (this.closedIds.includes(this.element.id)) this.element.open = false
  }

  save() {
    const ids = new Set(this.closedIds)
    this.element.open ? ids.delete(this.element.id) : ids.add(this.element.id)

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify([ ...ids ]))
    } catch {
      // Storage unavailable: collapsing still works, it just isn't remembered.
    }
  }

  get closedIds() {
    try {
      const ids = JSON.parse(localStorage.getItem(STORAGE_KEY))
      return Array.isArray(ids) ? ids : []
    } catch {
      return []
    }
  }
}
