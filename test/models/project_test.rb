require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  setup { @project = projects(:setenta) }

  test "lasts 75 days" do
    assert_equal Date.new(2026, 12, 14), @project.ends_on
    assert_equal 75, @project.days.count
  end

  test "numbers days from 1" do
    assert_equal 1, @project.day_number(Date.new(2026, 10, 1))
    assert_equal 12, @project.day_number(Date.new(2026, 10, 12))
    assert_equal 75, @project.day_number(Date.new(2026, 12, 14))
  end

  test "is upcoming before the start" do
    travel_to_day Date.new(2026, 9, 30)
    assert_equal :upcoming, @project.status
  end

  test "is active from the first to the last day" do
    travel_to_day Date.new(2026, 10, 1)
    assert_equal :active, @project.status

    travel_to_day Date.new(2026, 12, 14)
    assert_equal :active, @project.status
  end

  test "is finished after the last day" do
    travel_to_day Date.new(2026, 12, 15)
    assert_equal :finished, @project.status
  end

  test "elapsed days run from the start until today" do
    travel_to_day Date.new(2026, 10, 12)
    assert_equal 12, @project.elapsed_days.count
  end

  test "no elapsed days before the start" do
    travel_to_day Date.new(2026, 9, 30)
    assert_equal 0, @project.elapsed_days.count
  end

  test "elapsed days stop at the last day" do
    travel_to_day Date.new(2026, 12, 20)
    assert_equal 75, @project.elapsed_days.count
  end

  test "requires name and start date" do
    project = Project.new
    assert_not project.valid?
    assert project.errors.added?(:name, :blank)
    assert project.errors.added?(:starts_on, :blank)
  end
end
