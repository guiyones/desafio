require "test_helper"

class SlipTest < ActiveSupport::TestCase
  setup do
    travel_to_day Date.new(2026, 10, 12)
    @challenge = challenges(:refri)
  end

  test "valid on a past day inside the project" do
    assert @challenge.slips.new(day: Date.new(2026, 10, 10)).valid?
  end

  test "valid today" do
    assert @challenge.slips.new(day: Date.new(2026, 10, 12)).valid?
  end

  test "invalid before the project starts" do
    slip = @challenge.slips.new(day: Date.new(2026, 9, 30))
    assert_not slip.valid?
    assert_includes slip.errors[:day], "fora dos 75 dias do projeto"
  end

  test "invalid after the project ends" do
    travel_to_day Date.new(2026, 12, 20)
    slip = @challenge.slips.new(day: Date.new(2026, 12, 15))
    assert_not slip.valid?
    assert_includes slip.errors[:day], "fora dos 75 dias do projeto"
  end

  test "invalid in the future" do
    slip = @challenge.slips.new(day: Date.new(2026, 10, 13))
    assert_not slip.valid?
    assert_includes slip.errors[:day], "não pode ser no futuro"
  end

  test "invalid twice on the same day" do
    assert_not @challenge.slips.new(day: Date.new(2026, 10, 3)).valid?
  end

  test "invalid without a day" do
    assert_not @challenge.slips.new(day: nil).valid?
  end

  test "editable after the project ends" do
    travel_to_day Date.new(2026, 12, 20)
    assert @challenge.slips.new(day: Date.new(2026, 12, 14)).valid?
  end
end
