require "test_helper"

class SkillTest < ActiveSupport::TestCase
  setup { travel_to_day Date.new(2026, 10, 12) }

  test "xp sums every challenge that trains it" do
    assert_equal 210, skills(:controle).xp
    assert_equal 3, skills(:controle).level.number
  end

  test "a skill without challenges is level 1 with no xp" do
    assert_equal 0, skills(:jejum).xp
    assert_equal 1, skills(:jejum).level.number
  end

  test "xp keeps adding up across projects" do
    other = Project.create!(name: "Antes", starts_on: Date.new(2026, 7, 1))
    other.groups.create!(name: "G").challenges.create!(name: "Sem refri de novo", skill: skills(:controle))
    assert_equal 210 + 750, skills(:controle).xp
  end

  test "marking a slip removes exactly that day's xp" do
    assert_difference -> { skills(:controle).reload.xp }, -10 do
      challenges(:refri).slips.create!(day: Date.new(2026, 10, 10))
    end
  end

  test "upcoming projects give no xp" do
    future = Project.create!(name: "Depois", starts_on: Date.new(2026, 11, 1))
    future.groups.create!(name: "G").challenges.create!(name: "Jejum 16h", skill: skills(:jejum))
    assert_equal 0, skills(:jejum).xp
  end

  test "counts challenges in active projects" do
    assert_equal 2, skills(:controle).active_challenges_count
  end

  test "name is unique ignoring case" do
    assert_not Skill.new(name: "jejum", icon: "⏳").valid?
  end

  test "accepts multi codepoint emoji as icon" do
    assert Skill.new(name: "Cozinhar", icon: "👨‍🍳").valid?
  end

  test "destroying a skill keeps its challenges" do
    assert_no_difference -> { Challenge.count } do
      skills(:controle).destroy
    end
    assert_nil challenges(:refri).reload.skill
  end
end
