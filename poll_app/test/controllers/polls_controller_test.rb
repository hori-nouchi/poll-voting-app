require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get polls_index_url
    assert_response :success
  end

  test "should get show" do
    get polls_show_url
    assert_response :success
  end

  test "should get new" do
    get polls_new_url
    assert_response :success
  end

  test "should get result" do
    get polls_result_url
    assert_response :success
  end
end
