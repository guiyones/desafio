require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to_day Date.new(2026, 10, 12)
    @project = projects(:setenta)
  end

  test "index lists projects" do
    get root_path
    assert_response :success
    assert_select "a", text: "75 dias"
  end

  test "index goes straight to the only project" do
    projects(:vazio).destroy
    get root_path
    assert_redirected_to project_path(@project)
  end

  test "show renders progress and the grid" do
    get project_path(@project)
    assert_response :success
    assert_select "p", text: /dia 12 de 75/
    assert_select "#perfect_days", text: "10 dias perfeitos"
    assert_select "h3", text: /Sem refrigerante/
    assert_select ".day--slipped a[aria-label='Dia 3: vacilo, editar']", count: 2
    assert_select ".day--kept button[aria-label='Dia 4: marcar vacilo']", count: 3
    assert_select ".day--future span", count: 3 * 63
    assert_select ".day--today", count: 3
    assert_select ".hud", text: /fase 1/
    assert_select ".mission", count: 3
    assert_select ".mission .skill-tag", text: /Controle/, count: 2
    assert_select ".mission", text: /\+110 XP/
  end

  test "groups are collapsible and start open" do
    get project_path(@project)
    assert_select "details.group[open][data-controller='group-toggle']", count: 2
    assert_select "details.group summary h2", text: "Alimentação"
  end

  test "a mission without skill has no tag" do
    challenges(:caminhada).update!(skill: nil)
    get project_path(@project)
    assert_select ".mission .skill-tag", count: 2
  end

  test "new" do
    get new_project_path
    assert_response :success
  end

  test "creates a project" do
    assert_difference -> { Project.count } do
      post projects_path, params: { project: { name: "Comer melhor", starts_on: "2026-10-12" } }
    end
    assert_redirected_to project_path(Project.last)
  end

  test "rejects a project without a name" do
    post projects_path, params: { project: { name: "", starts_on: "2026-10-12" } }
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_project_path(@project)
    assert_response :success
  end

  test "updates a project" do
    patch project_path(@project), params: { project: { name: "Setenta e cinco" } }
    assert_redirected_to project_path(@project)
    assert_equal "Setenta e cinco", @project.reload.name
  end

  test "rejects changing the start date once slips exist" do
    patch project_path(@project), params: { project: { starts_on: "2026-10-02" } }
    assert_response :unprocessable_content
  end

  test "destroys a project" do
    assert_difference -> { Project.count } => -1, -> { Slip.count } => -3 do
      delete project_path(@project)
    end
    assert_redirected_to projects_path
  end
end
