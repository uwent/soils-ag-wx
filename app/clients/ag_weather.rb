module AgWeather
  BASE_URL = ENV["AG_WEATHER_BASE_URL"] || "http://localhost:8080"
  HOST = ENV["AG_WEATHER_HOST"] || "http://localhost:8080"

  PRECIP_URL = BASE_URL + "/precips"
  WEATHER_URL = BASE_URL + "/weather"
  INSOL_URL = BASE_URL + "/insolations"
  ET_URL = BASE_URL + "/evapotranspirations"
  DD_URL = BASE_URL + "/degree_days"
  PEST_URL = BASE_URL + "/pest_forecasts"

  def self.get(url, query: nil, timeout: 10)
    response = HTTParty.get(url, query: query, timeout: timeout)
    JSON.parse(response.body, symbolize_names: true)
  rescue
    Rails.logger.error "Failed to retrieve endpoint #{url}"
  end

  def self.get_map(endpoint, id, query)
    url = "#{endpoint}/#{id}"
    json = get(url, query: query, timeout: 30)
    "#{HOST}#{json[:map]}"
  rescue
    Rails.logger.error "Failed to retrieve map image at #{url}"
    "/no_data.png"
  end

  def self.get_grid(endpoint, date)
    url = endpoint + "/all_for_date"
    json = get(url, query: {date: date})
    json[:data]
  rescue
    Rails.logger.error "Failed to retrieve data grid at #{url}"
    []
  end

  # def self.get_dd_grid(model, opts = {})
  #   json = get(PEST_URL, {pest: model})
  #   json[:data]
  # rescue
  #   Rails.logger.error "Failed to retrieve pest/dd data grid at #{url}"
  #   []
  # end

  def self.get_et_value(date, lat, long)
    url = ET_URL.to_s
    opts = {
      start_date: date,
      end_date: date,
      lat: lat,
      long: long
    }
    json = get(url, query: opts)
    data = json[:data]
    data.length > 0 ? data[0][:value].to_f : -1.0
  end
end
