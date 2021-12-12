module AgWeather
  BASE_URL = ENV["AG_WEATHER_BASE_URL"] || "http://localhost:8080"
  HOST = ENV["AG_WEATHER_HOST"] || "http://localhost:8080"

  PRECIP_URL = BASE_URL + "/precips"
  WEATHER_URL = BASE_URL + "/weather"
  INSOL_URL = BASE_URL + "/insolations"
  ET_URL = BASE_URL + "/evapotranspirations"
  DD_URL = BASE_URL + "/degree_days"
  PEST_URL = BASE_URL + "/pest_forecasts"

  def self.get(endpoint, query = nil, timeout = 5)
    response = HTTParty.get(endpoint, query: query, timeout: timeout)
    JSON.parse(response.body, symbolize_names: true)
  rescue
    Rails.logger.error "Failed to retrieve endpoint #{url}"
  end

  def self.get_map(endpoint, date)
    url = "#{endpoint}/#{date}"
    json = get(url)
    "#{HOST}#{json[:map]}"
  rescue
    Rails.logger.error "Failed to retrieve map image at #{url}"
    "/no_data.png"
  end

  def self.get_dd_map(model, opts = {})
    url = "#{PEST_URL}/#{model}"
    json = get(url, opts, 30)
    "#{HOST}#{json[:map]}"
  rescue
    Rails.logger.error "Failed to retrieve map image at #{url}"
    "/no_data.png"
  end

  def self.get_grid(endpoint, date)
    url = endpoint + "/all_for_date"
    json = get(url, {date: date})
    json[:data]
  rescue
    Rails.logger.error "Failed to retrieve data grid at #{url}"
    []
  end

  def self.get_dd_grid(model, opts = {})
    json = get(PEST_URL, {pest: model})
    json[:data]
  rescue
    Rails.logger.error "Failed to retrieve pest/dd data grid at #{url}"
    []
  end
end
