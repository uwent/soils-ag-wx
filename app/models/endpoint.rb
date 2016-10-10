class Endpoint
  BASE_URL = ENV['AG_WEATHER_BASE_URL'] || 'http://localhost:3000'
  HOST = ENV['AG_WEATHER_HOST'] || 'http://localhost:3000'

  def self.get_et_value(date, lat, long)
    endpoint = "#{BASE_URL}/evapotranspirations?start_date=#{date.strftime('%Y-%m-%d')}&end_date=#{date.strftime('%Y-%m-%d')}&lat=#{lat}&long=#{long}"
    resp = HTTParty.get(endpoint, { timeout: 10 })
    body = JSON.parse(resp.body)
    return body.length > 0 ? body[0]['value'].to_f : -1.0
  end

end
