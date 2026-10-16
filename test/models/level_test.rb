require "test_helper"

class LevelTest < ActiveSupport::TestCase
  test "thresholds follow 25 * n * (n - 1)" do
    assert_equal [ 0, 50, 150, 300, 500 ], (1..5).map { Level.threshold(it) }
  end

  test "levels by xp" do
    assert_equal [ 1, 1, 2, 2, 3, 6 ], [ 0, 49, 50, 149, 150, 750 ].map { Level.for(it).number }
  end

  test "progress inside the level" do
    level = Level.for(120)
    assert_equal 2, level.number
    assert_equal 70, level.xp_into
    assert_equal 100, level.xp_needed
  end
end
