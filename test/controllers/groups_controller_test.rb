require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup { @project = projects(:setenta) }

  test "new" do
    get new_project_group_path(@project)
    assert_response :success
  end

  test "creates a group" do
    assert_difference -> { @project.groups.count } do
      post project_groups_path(@project), params: { group: { name: "Sono" } }
    end
    assert_redirected_to project_path(@project)
  end

  test "rejects a blank name" do
    post project_groups_path(@project), params: { group: { name: "" } }
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_group_path(groups(:treino))
    assert_response :success
  end

  test "renames a group" do
    patch group_path(groups(:treino)), params: { group: { name: "Exercício" } }
    assert_redirected_to project_path(@project)
    assert_equal "Exercício", groups(:treino).reload.name
  end

  test "destroys a group with its challenges and slips" do
    assert_difference -> { Challenge.count } => -2, -> { Slip.count } => -3 do
      delete group_path(groups(:alimentacao))
    end
    assert_redirected_to project_path(@project)
  end
end
