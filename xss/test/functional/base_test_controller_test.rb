require 'test_helper'

class BaseTestControllerTest < ActionController::TestCase
  test "should get sanitizers_form" do
    get :sanitizers_form
    assert_response :success
  end

  test "should get sanitizers_perform" do
    get :sanitizers_perform
    assert_response :success
  end

end
