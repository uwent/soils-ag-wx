module AgWeather
  BASE_URL = ENV["AG_WEATHER_BASE_URL"] || "http://localhost:8080"
  HOST = ENV["AG_WEATHER_HOST"] || "http://localhost:8080"

  PRECIP_URL = BASE_URL + "/precips"
  WEATHER_URL = BASE_URL + "/weather"
  FORECAST_URL = WEATHER_URL + "/forecast"
  INSOL_URL = BASE_URL + "/insolations"
  ET_URL = BASE_URL + "/evapotranspirations"
  DD_URL = BASE_URL + "/degree_days"
  DD_TABLE_URL = BASE_URL + "/degree_days/dd_table"
  PEST_URL = BASE_URL + "/pest_forecasts"

  def self.get(url, query: nil, timeout: 10, symbolize_names: true)
    response = HTTParty.get(url, query:, timeout:)
    JSON.parse(response.body, symbolize_names:)
  rescue
    Rails.logger.error "Failed to retrieve endpoint #{url}"
    {}
  end

  def self.get_weather(query:)
    get(WEATHER_URL, query:)&.dig(:data) || {}
  end

  def self.get_precip(query:)
    get(PRECIP_URL, query:)&.dig(:data) || {}
  end

  def self.get_et(query:)
    get(ET_URL, query:)&.dig(:data) || {}
  end

  def self.get_insol(query:)
    get(INSOL_URL, query:)&.dig(:data) || {}
  end

  def self.get_dd(query:)
    get(DD_URL, query:)&.dig(:data) || {}
  end

  def self.get_dd_table(query:)
    get(DD_TABLE_URL, query:, symbolize_names: false) || {}
  end

  def self.get_map(endpoint, date, query)
    url = "#{endpoint}/map?date=#{date}"
    json = get(url, query:, timeout: 60)
    map = json[:url]
    map ? "#{HOST}#{map}" : "/no_data.png"
  rescue
    Rails.logger.error "Failed to retrieve map image at #{url}"
    "/no_data.png"
  end

  def self.get_grid(endpoint, date)
    url = endpoint + "/grid"
    json = get(url, query: {date:})
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

  # def self.get_et_values(lat, long, date, start_date = nil)
  #   url = ET_URL
  #   opts = {
  #     lat: lat,
  #     long: long,
  #     start_date: start_date,
  #     end_date: date
  #   }.compact
  #   json = get(url, query: opts)
  #   data = json[:data]
  # end
end
