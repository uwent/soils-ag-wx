require "test_helper"

class SunWaterControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get et_map" do
    get :et_map
    assert_response :success
  end

  test "should post et_map" do
    post :et_map
    assert_response :success
  end

  test "should get insol_map" do
    get :insol_map
    assert_response :success
  end

  test "should post insol_map" do
    post :insol_map
    assert_response :success
  end
end
