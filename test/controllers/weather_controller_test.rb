require "test_helper"

class WeatherControllerTest < ActionController::TestCase
  date = "2021-01-01"
  map_response = {map: "no_data.png"}.to_json

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get doycal" do
    get :doycal
    assert_response :success
  end

  test "should get weather_map" do
    stub_request(:get, "https://www.example.com/weather/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :weather_map
    assert_response :success
  end

  test "should post weather_map" do
    stub_request(:get, "https://www.example.com/weather/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :weather_map, params: {date: date}
    assert_response :success
  end

  test "should post map_image for weather" do
    stub_request(:get, "https://www.example.com/weather/#{date}").to_return(status: 200, body: map_response)
    post :map_image, body: {endpoint: AgWeather::WEATHER_URL, id: date, query: {}}.to_json
    assert_response :success
  end

  test "should get precip_map" do
    stub_request(:get, "https://www.example.com/precips/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :precip_map
    assert_response :success
  end

  test "should post precip_map" do
    stub_request(:get, "https://www.example.com/precips/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :precip_map, params: {date: date}
    assert_response :success
  end

  test "should post map_image for precips" do
    stub_request(:get, "https://www.example.com/precips/#{date}").to_return(status: 200, body: map_response)
    post :map_image, body: {endpoint: AgWeather::PRECIP_URL, id: date, query: {}}.to_json
    assert_response :success
  end

  test "should get hyd" do
    get :hyd
    assert_response :success
  end

  test "should get webcam" do
    skip "deprecated"
    get :webcam
    assert_response :success
  end
end
