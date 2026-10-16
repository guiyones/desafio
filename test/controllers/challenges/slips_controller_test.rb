require "test_helper"

class Challenges::SlipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to_day Date.new(2026, 10, 12)
    @challenge = challenges(:refri)
  end

  test "marks a slip and swaps the day and the counter" do
    assert_difference -> { @challenge.slips.count } do
      post challenge_slips_path(@challenge), params: { day: "2026-10-10" }, as: :turbo_stream
    end

    assert_response :success
    assert_turbo_stream action: :replace, target: "day_2026-10-10_challenge_#{@challenge.id}"
    assert_turbo_stream action: :replace, target: "perfect_days"
    assert_match edit_challenge_slip_path(@challenge, "2026-10-10"), response.body
  end

  test "marks a slip without turbo" do
    post challenge_slips_path(@challenge), params: { day: "2026-10-10" }
    assert_redirected_to project_path(projects(:setenta), anchor: dom_id(@challenge))
  end

  test "refuses a future day" do
    assert_no_difference -> { Slip.count } do
      post challenge_slips_path(@challenge), params: { day: "2026-10-13" }, as: :turbo_stream
    end
    assert_response :unprocessable_content
  end

  test "refuses a day outside the project" do
    post challenge_slips_path(@challenge), params: { day: "2026-09-30" }, as: :turbo_stream
    assert_response :unprocessable_content
  end

  test "refuses garbage" do
    post challenge_slips_path(@challenge), params: { day: "ontem" }, as: :turbo_stream
    assert_response :unprocessable_content
  end

  test "edit shows the note" do
    get edit_challenge_slip_path(@challenge, "2026-10-03")
    assert_response :success
    assert_select "input[value='aniversário']"
  end

  test "edit of a day without slip is not found" do
    get edit_challenge_slip_path(@challenge, "2026-10-04")
    assert_response :not_found
  end

  test "updates the note" do
    patch challenge_slip_path(@challenge, "2026-10-03"), params: { slip: { note: "bolo da tia" } }
    assert_redirected_to project_path(projects(:setenta), anchor: dom_id(@challenge))
    assert_equal "bolo da tia", slips(:refri_day3).reload.note
  end

  test "removes a slip" do
    assert_difference -> { @challenge.slips.count }, -1 do
      delete challenge_slip_path(@challenge, "2026-10-03")
    end
    assert_redirected_to project_path(projects(:setenta), anchor: dom_id(@challenge))
  end
end
