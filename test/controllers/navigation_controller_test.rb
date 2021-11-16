require "test_helper"

class NavigationControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get king_hall" do
    get :king_hall
    assert_response :success
  end
end
