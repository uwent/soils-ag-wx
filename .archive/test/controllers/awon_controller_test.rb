require "test_helper"

class AwonControllerTest < ActionController::TestCase
  test "should get awon_check_boxes" do
    get :awon_check_boxes
    assert_response :success
  end

  test "should get station_info" do
    get :station_info
    assert_response :success
  end

  # test "should get blog" do
  #   blogs(:one)
  #   get :blog
  #   assert_response :success
  # end

  # test "should get awon_seven_day" do
  #   get :awon_seven_day
  #   assert_response :success
  # end

  test "should get download_data" do
    get :download_data
    assert_response :success
  end

  test "should post download_data" do
    post :download_data
    assert_response :success
  end
end
