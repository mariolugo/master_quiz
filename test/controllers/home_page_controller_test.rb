require 'test_helper'

class HomePageControllerTest < ActionDispatch::IntegrationTest

  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Master quiz"
  end

  test "should get help" do
    get help_path
    assert_response :success
    assert_select "title", "Help | Master quiz"
  end

end
