require "test_helper"

class SkillsHelperTest < ActionView::TestCase
  test "banner carries each skill level as data" do
    travel_to_day Date.new(2026, 10, 12)
    html = level_up_banner([ skills(:controle) ])

    assert_includes html, 'data-controller="level-up"'
    assert_includes html, "hidden"

    data = Nokogiri::HTML5.fragment(html).at_css("[data-level-up-skills-value]")["data-level-up-skills-value"]
    skills_data = JSON.parse(data)

    assert_equal [ { "id" => skills(:controle).id, "name" => "Controle", "level" => 3 } ], skills_data
  end
end
