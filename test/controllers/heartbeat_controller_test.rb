require 'test_helper'

class HeartbeatControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get awon" do
    awon_stations(:one).update!(stnid: 4751)
    awon_stations(:two).update!(stnid: 4781)
    get :awon
    assert_response :success
  end

  test "should get asos" do
    asos_stations(:one)
    get :asos
    assert_response :success
  end

  # test "should get hyd" do
  #     assigns(:hyd_res) { [] }
  #   get :hyd
  #   assert_response :success
  # end

  test "should get dd" do
    get :dd
    assert_response :success
  end

  test "should get et" do
    get :et
    assert_response :success
  end

  test "should get insol" do
    get :insol
    assert_response :success
  end

  test "should get ping" do
    get :ping
    assert_response :success
  end

  test "should get webapps" do
    get :webapps
    assert_response :success
  end

  test "should get asos grids" do
    get :asos_grids
    assert_response :success
  end

end
