module AgWeather
  BASE_URL = ENV["AG_WEATHER_BASE_URL"] || "http://localhost:8080"
  HOST = ENV["AG_WEATHER_HOST"] || "http://localhost:8080"

  PRECIP_URL = BASE_URL + "/precips"
  WEATHER_URL = BASE_URL + "/weather"
  INSOL_URL = BASE_URL + "/insolations"
  ET_URL = BASE_URL + "/evapotranspirations"
  DD_URL = BASE_URL + "/degree_days"

  def self.get(endpoint, query = nil)
    response = HTTParty.get(endpoint, query: query, timeout: 5)
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
    "no_data.png"
  end

  def self.get_grid(endpoint, date)
    url = endpoint + "/all_for_date"
    json = get(url, {date: date})
    json[:data]
  end

end
