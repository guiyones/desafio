require "application_system_test_case"

class LevelUpTest < ApplicationSystemTestCase
  setup do
    visit skills_path
    page.execute_script("try { localStorage.clear() } catch (e) {}")
  end

  test "banner contract: first visit registers, higher level shows, seen level hides, corrupt storage is ignored" do
    skill = skills(:controle)
    current_level = skill.reload.level.number
    previous_level = [ current_level - 1, 0 ].max

    # First visit after a clean storage: no previous high-water mark, so nothing to compare against.
    visit skills_path
    assert_no_text "LEVEL UP"

    # Simulate having last seen a lower level: the skill's level now exceeds it, banner should show.
    page.execute_script(<<~JS)
      localStorage.setItem("desafio:max-levels", JSON.stringify({ #{skill.id}: #{previous_level} }))
    JS
    visit skills_path
    assert_text "★ LEVEL UP! ★"
    assert_text "#{skill.name} chegou ao NV #{current_level}"

    # Reload again: the level was already recorded as seen, so no banner this time.
    visit skills_path
    assert_no_text "LEVEL UP"

    # Corrupt JSON in storage: treated as empty, no banner, and the page still renders fine (no JS crash).
    page.execute_script('localStorage.setItem("desafio:max-levels", "{lixo")')
    visit skills_path
    assert_no_text "LEVEL UP"
    assert_text "PERSONAGEM"
  end
end
