require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test "should be valid" do
    assert @question.valid?
  end

  test "name should be present" do
    @user.content = "     "
    assert_not @question.valid?
  end
end
