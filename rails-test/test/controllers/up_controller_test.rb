require "test_helper"

class UpControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get up_index_url
    assert_response :success
  end
end
