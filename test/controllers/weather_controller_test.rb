require "test_helper"
require "application_controller"

class WeatherControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get doycal" do
    get :doycal
    assert_response :success
  end

  test "should get grid_temps" do
    get :grid_temps
    assert_response :success
  end

  test "should get hyd" do
    get :hyd
    assert_response :success
  end

  test "should get kinghall" do
    get :kinghall
    assert_response :success
  end

  test "should get webcam" do
    get :webcam
    assert_response :success
  end
end
