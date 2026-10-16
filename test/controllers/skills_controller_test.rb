require "test_helper"

class SkillsControllerTest < ActionDispatch::IntegrationTest
  setup { travel_to_day Date.new(2026, 10, 12) }

  test "character sheet shows level and skills" do
    get skills_path
    assert_response :success
    assert_select ".hud", text: /PERSONAGEM/
    assert_select ".hud", text: /NV 4/
    assert_select ".skill-card", count: 3
    assert_select ".skill-card", text: /Controle.*NV 3.*60\/150 XP.*2 missões/m
    assert_select ".skill-card", text: /Jejum.*NV 1.*0\/50 XP/m
  end

  test "empty sheet invites to create the first skill" do
    Skill.destroy_all
    get skills_path
    assert_select "p", text: /Crie sua primeira skill/
  end

  test "creates a skill" do
    assert_difference -> { Skill.count } do
      post skills_path, params: { skill: { name: "Sono", icon: "😴" } }
    end
    assert_redirected_to skills_path
  end

  test "rejects a duplicate name" do
    post skills_path, params: { skill: { name: "controle", icon: "🛡" } }
    assert_response :unprocessable_content
  end

  test "edits a skill" do
    patch skill_path(skills(:jejum)), params: { skill: { name: "Jejum intermitente" } }
    assert_redirected_to skills_path
    assert_equal "Jejum intermitente", skills(:jejum).reload.name
  end

  test "destroys a skill and frees its challenges" do
    delete skill_path(skills(:controle))
    assert_redirected_to skills_path
    assert_nil challenges(:refri).reload.skill
  end
end
