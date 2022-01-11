require "test_helper"

class SunWaterControllerTest < ActionController::TestCase
  date = "2021-01-01"
  map_response = {map: "no_data.png"}.to_json

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get et_map" do
    stub_request(:get, "https://www.example.com/evapotranspirations/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :et_map
    assert_response :success
  end

  test "should post et_map" do
    stub_request(:get, "https://www.example.com/evapotranspirations/#{date}").to_return(status: 200, body: map_response, headers: {})
    post :et_map, params: {date:}
    assert_response :success
  end

  test "should post map_image for ET" do
    stub_request(:get, "https://www.example.com/evapotranspirations/#{date}").to_return(status: 200, body: map_response)
    post :map_image, body: {endpoint: AgWeather::ET_URL, id: date, query: {}}.to_json
    assert_response :success
  end

  test "should get insol_map" do
    stub_request(:get, "https://www.example.com/insolations/#{date}").to_return(status: 200, body: map_response, headers: {})
    get :insol_map
    assert_response :success
  end

  test "should post insol_map" do
    stub_request(:get, "https://www.example.com/insolations/#{date}").to_return(status: 200, body: map_response, headers: {})
    post :insol_map, params: {date:}
    assert_response :success
  end

  test "should post map_image for insols" do
    stub_request(:get, "https://www.example.com/insolations/#{date}").to_return(status: 200, body: map_response, headers: {})
    post :map_image, body: {endpoint: AgWeather::INSOL_URL, id: date, query: {}}.to_json
    assert_response :success
  end
end
