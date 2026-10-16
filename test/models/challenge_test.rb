require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  setup do
    travel_to_day Date.new(2026, 10, 12)
    @challenge = challenges(:refri)
  end

  test "a day with a slip is slipped" do
    assert_equal :slipped, @challenge.status_on(Date.new(2026, 10, 3))
  end

  test "a past day without a slip is kept" do
    assert_equal :kept, @challenge.status_on(Date.new(2026, 10, 4))
  end

  test "today is kept until a slip is marked" do
    assert_equal :kept, @challenge.status_on(Date.new(2026, 10, 12))
  end

  test "tomorrow is future" do
    assert_equal :future, @challenge.status_on(Date.new(2026, 10, 13))
  end

  test "reaches its project through the group" do
    assert_equal projects(:setenta), @challenge.project
  end

  test "counts slips and kept days" do
    assert_equal 1, @challenge.slips_count
    assert_equal 11, @challenge.kept_count
    assert_equal 92, @challenge.kept_percentage
  end

  test "kept percentage is zero before the start" do
    travel_to_day Date.new(2026, 9, 20)
    assert_equal 0, @challenge.kept_percentage
  end

  test "kept count is capped after the project ends" do
    travel_to_day Date.new(2026, 12, 20)
    assert_equal 74, @challenge.kept_count
  end

  test "xp is kept days times xp per day" do
    assert_equal 110, @challenge.xp
  end

  test "a challenge without a skill is still valid" do
    challenges(:caminhada).update!(skill: nil)
    assert challenges(:caminhada).valid?
  end
end
