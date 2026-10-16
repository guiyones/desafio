require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "sums the slips of its challenges" do
    assert_equal 3, groups(:alimentacao).slips_count
    assert_equal 0, groups(:treino).slips_count
  end
end
