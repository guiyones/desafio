require "test_helper"

class ProjectsHelperTest < ActionView::TestCase
  setup { @project = projects(:setenta) }

  test "upcoming project" do
    travel_to_day Date.new(2026, 9, 30)
    assert_equal "começa em 01/10", project_progress(@project)
  end

  test "active project" do
    travel_to_day Date.new(2026, 10, 12)
    assert_equal "dia 12 de 75", project_progress(@project)
  end

  test "finished project" do
    travel_to_day Date.new(2026, 12, 15)
    assert_equal "terminou em 14/12", project_progress(@project)
  end
end
