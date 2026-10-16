require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:alimentacao)
    @project = projects(:setenta)
  end

  test "new" do
    get new_group_challenge_path(@group)
    assert_response :success
  end

  test "creates a challenge" do
    assert_difference -> { @group.challenges.count } do
      post group_challenges_path(@group), params: { challenge: { name: "Sem fritura" } }
    end
    assert_redirected_to project_path(@project)
  end

  test "rejects a blank name" do
    post group_challenges_path(@group), params: { challenge: { name: "" } }
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_challenge_path(challenges(:refri))
    assert_response :success
  end

  test "renames a challenge" do
    patch challenge_path(challenges(:refri)), params: { challenge: { name: "Zero refri" } }
    assert_redirected_to project_path(@project)
    assert_equal "Zero refri", challenges(:refri).reload.name
  end

  test "destroys a challenge with its slips" do
    assert_difference -> { Challenge.count } => -1, -> { Slip.count } => -2 do
      delete challenge_path(challenges(:doce))
    end
    assert_redirected_to project_path(@project)
  end
end
