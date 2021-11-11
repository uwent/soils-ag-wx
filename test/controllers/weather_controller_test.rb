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

  test "should get weather_map" do
    get :weather_map
    assert_response :success
  end

  test "should get precip_map" do
    get :precip_map
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
