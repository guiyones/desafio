import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "desafio:max-levels"

export default class extends Controller {
  static targets = [ "headline", "lines" ]
  static values = { skills: Array }

  connect() {
    this.element.hidden = true

    const skills = this.skillsValue
    if (skills.length === 0) return

    let raw
    try {
      raw = localStorage.getItem(STORAGE_KEY)
    } catch (error) {
      return
    }

    let maxLevels
    try {
      maxLevels = raw ? JSON.parse(raw) : {}
      if (typeof maxLevels !== "object" || maxLevels === null || Array.isArray(maxLevels)) {
        maxLevels = {}
      }
    } catch (error) {
      maxLevels = {}
    }

    const leveledUp = []
    const updated = { ...maxLevels }

    skills.forEach((skill) => {
      const previous = maxLevels[skill.id]

      if (previous !== undefined && skill.level > previous) {
        leveledUp.push(skill)
      }

      updated[skill.id] = previous === undefined ? skill.level : Math.max(previous, skill.level)
    })

    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated))
    } catch (error) {
      // ignore storage write errors
    }

    if (leveledUp.length > 0) this.show(leveledUp)
  }

  show(leveledUp) {
    this.headlineTarget.textContent = "★ LEVEL UP! ★"
    this.linesTarget.textContent = leveledUp.map((skill) => `${skill.name} chegou ao NV ${skill.level}`).join("\n")
    this.element.hidden = false
  }

  dismiss() {
    this.element.hidden = true
  }
}
