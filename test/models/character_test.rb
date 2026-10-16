require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  test "sums all skills and levels with the same curve" do
    travel_to_day Date.new(2026, 10, 12)
    character = Character.new

    assert_equal 330, character.xp
    assert_equal 4, character.level.number
  end
end
