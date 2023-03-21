require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get calendar_url
    assert_response :success
  end
end
