class Endpoint
  BASE_URL = ENV['AG_WEATHER_BASE_URL'] || 'http://localhost:8080'
  HOST = ENV['AG_WEATHER_HOST'] || 'http://localhost:8080'
  
  def self.get_et_value(date, lat, long)
    endpoint = "#{BASE_URL}/evapotranspirations?start_date=#{date.strftime('%Y-%m-%d')}&end_date=#{date.strftime('%Y-%m-%d')}&lat=#{lat}&long=#{long}"
    resp = HTTParty.get(endpoint, { timeout: 10 })
    json = JSON.parse(resp.body)
    data = json["data"]
    data.length > 0 ? data[0]['value'].to_f : -1.0
  end

end
