require "application_system_test_case"

class SkillsFlowTest < ApplicationSystemTestCase
  test "create a skill, train it with a challenge and see the xp on the sheet" do
    travel_to_day Date.new(2026, 10, 12)

    visit skills_path
    click_on "+ Nova skill"
    fill_in "Nome", with: "Jejum longo"
    fill_in "Ícone", with: "⏳"
    click_on "Criar skill"
    assert_text "Jejum longo"

    visit project_path(projects(:setenta))
    click_on "Novo desafio", match: :first
    fill_in "Nome", with: "Jejum 16h"
    select "⏳ Jejum longo", from: "Skill"
    click_on "Criar desafio"
    assert_text "+120 XP"

    visit skills_path
    assert_text "450 XP no total"
    within(".skill-card", text: "Jejum longo") { assert_text "70/100 XP" }
  end
end
