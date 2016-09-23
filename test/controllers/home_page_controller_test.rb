require 'test_helper'

class HomePageControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "Master quiz"
  end

  test "should get home" do
    get home_page_home_url
    assert_response :success
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get help" do
    get home_page_help_url
    assert_response :success
  end

end
