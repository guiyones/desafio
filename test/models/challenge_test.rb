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
end
