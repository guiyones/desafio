require "test_helper"

class Projects::ResultsControllerTest < ActionDispatch::IntegrationTest
  setup { travel_to_day Date.new(2026, 10, 12) }

  test "shows totals, numbers per challenge and the timeline" do
    get project_results_path(projects(:setenta))

    assert_response :success
    assert_select "#elapsed_days_count", "12 de 75"
    assert_select "#perfect_days_count", "10"
    assert_select "#slips_count", "3"
    assert_select "tr", text: /Sem refrigerante\s+1\s+11\s+92%\s+110 XP/
    assert_select "tr", text: /Sem doce\s+2\s+10\s+83%\s+100 XP/
    assert_select "li", text: "Dia 3 · Sem refrigerante · aniversário"
    assert_select "li", text: "Dia 5 · Sem doce"
  end

  test "says so when there are no slips" do
    get project_results_path(projects(:vazio))
    assert_response :success
    assert_select "p", text: "Nenhum vacilo até agora."
  end
end
