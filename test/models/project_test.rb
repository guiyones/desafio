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

  test "blocks changing the start date once slips exist" do
    @project.starts_on = Date.new(2026, 10, 2)
    assert_not @project.valid?(:update)
    assert_includes @project.errors[:starts_on], "não pode mudar depois de marcar vacilos"
  end

  test "allows changing the start date without slips" do
    project = projects(:vazio)
    project.starts_on = Date.new(2026, 10, 2)
    assert project.valid?(:update)
  end

  test "counts every slip" do
    travel_to_day Date.new(2026, 10, 12)
    assert_equal 3, @project.slips_count
  end

  test "perfect days are elapsed days without any slip" do
    travel_to_day Date.new(2026, 10, 12)
    perfect = @project.perfect_days

    assert_equal 10, perfect.size
    assert_not_includes perfect, Date.new(2026, 10, 3)
    assert_not_includes perfect, Date.new(2026, 10, 5)
  end

  test "no perfect days without challenges" do
    travel_to_day Date.new(2026, 10, 12)
    assert_empty projects(:vazio).perfect_days
  end

  test "no perfect days before the start" do
    travel_to_day Date.new(2026, 9, 30)
    assert_empty @project.perfect_days
  end

  test "timeline lists slips by day" do
    timeline = @project.slips_timeline
    assert_equal [ Date.new(2026, 10, 3), Date.new(2026, 10, 3), Date.new(2026, 10, 5) ], timeline.map(&:day)
  end

  test "destroying removes everything below it" do
    assert_difference -> { Slip.count } => -3, -> { Challenge.count } => -3, -> { Group.count } => -2 do
      @project.destroy
    end
  end

  test "phases split the 75 days into 5 chunks of 15" do
    assert_equal 1, @project.phase_on(Date.new(2026, 10, 1))
    assert_equal 1, @project.phase_on(Date.new(2026, 10, 15))
    assert_equal 2, @project.phase_on(Date.new(2026, 10, 16))
    assert_equal 5, @project.phase_on(Date.new(2026, 12, 14))
  end
end
