class ForecastSub < WeatherSub
  API_KEY = ENV["WEATHERAPI_KEY"]

  def partial
    "forecast"
  end

  def fetch(sites = self.sites.enabled)
    # make sure its an array
    sites = sites.is_a?(Site) ? [sites] : sites
    return unless sites.size > 0

    sites = sites.collect { |site| [site.latitude, site.longitude] }
    all_data = {}

    sites.each do |site|
      lat, long = site
      url = "https://api.weatherapi.com/v1/forecast.json"
      query = {
        key: API_KEY,
        q: "#{lat},#{long}",
        days: 3,
        aqi: "no",
        alerts: "no"
      }
      response = HTTParty.get(url, query:, timeout: 5)
      json = JSON.parse(response.body, symbolize_names: true)
      forecasts = json[:forecast][:forecastday]

      # collect and format data for each date
      site_data = []
      forecasts.each do |fc|
        day = fc[:day]
        hourly = fc[:hour]
        datestring = fc[:date]
        forecast = []

        # conditions
        condition = day[:condition][:text]
        icon = day[:condition][:icon]
        forecast << condition

        # temperature
        min_temp = day[:mintemp_f]
        max_temp = day[:maxtemp_f]
        forecast << "High #{num_fmt(max_temp, 0)}°F, low #{num_fmt(min_temp, 0)}°F"
        if (max_temp > 32) && (min_temp <= 32)
          forecast << "Frost expected" if min_temp === (28..32)
          forecast << "Hard freeze expected" if min_temp <= 28
        end

        # precip
        rain_chance = day[:daily_chance_of_rain] || 0
        snow_chance = day[:daily_chance_of_snow] || 0
        total_precip = day[:totalprecip_in] || 0
        hourly_precips = hourly.select { |h| Time.parse(h[:time]) >= Time.current }.collect { |h| h[:precip_in] }
        total_hourly_precip = hourly_precips.sum || 0
        precip = ""
        precip += "#{rain_chance}% chance of rain, " if rain_chance > 0
        precip += "#{snow_chance}% chance of snow, " if snow_chance > 0
        if total_precip > 0
          precip += "total precip #{num_fmt(total_precip, 2)} in"
          if Date.parse(datestring) == Date.current && total_hourly_precip < total_precip
            precip += ". (#{num_fmt(total_hourly_precip, 2)} in. remaining)"
          end
        end
        precip = "No precipitation expected" if precip == ""
        forecast << precip

        # humidity
        hums = hourly.map { |h| h[:humidity] }
        min_hum = num_fmt(hums.min, 0)
        max_hum = num_fmt(hums.max, 0)
        humidity = min_hum == max_hum ? min_hum : "#{min_hum}-#{max_hum}"
        forecast << "Humidity #{humidity}%"

        # wind. Use vector addition to find the speed-weighted average wind direction for the day
        wind_vecs = hourly.map { |h| Complex.polar(h[:wind_mph], h[:wind_degree] * 2 * Math::PI / 360) }
        wind_speed, wind_radian = (wind_vecs.sum / wind_vecs.size).polar
        wind_deg = 360 * wind_radian / (2 * Math::PI)
        wind_bearing = get_bearing(wind_deg)
        wind_speeds = hourly.map { |h| h[:wind_mph] }
        wind_gusts = hourly.map { |h| h[:gust_mph] }
        min_wind = num_fmt(wind_speeds.min, 0)
        max_wind = num_fmt(wind_speeds.max, 0)
        avg_wind = num_fmt(wind_speed, 0)
        # wind = min_wind == max_wind ? "#{min_wind} mph" : "#{min_wind}-#{max_wind} mph, average #{avg_wind} mph"
        wind_range = min_wind == max_wind ? "" : "range #{min_wind}-#{max_wind} mph, "
        forecast << "Wind #{wind_severity(wind_speed)} #{num_fmt(wind_speed, 0)} mph #{wind_bearing}, #{wind_range}gusts up to #{num_fmt(wind_gusts.max, 0)} mph"

        # uv
        uv_index = day[:uv].to_i
        uv_risk = uv_severity(uv_index)
        forecast << "UV index #{uv_index}, #{uv_risk}"

        site_data << {
          date: date_fmt(Date.parse(datestring)),
          forecast: forecast.join(". ") + ".",
          icon:,
          min_temp:,
          max_temp:,
          total_precip:,
          max_wind:,
        }
      end

      all_data[[lat, long].to_s] = site_data
    end
    all_data
  rescue
    Rails.logger.error "ForecastSub :: Failed to retrieve data for sites."
    {}
  end

  def median(arr)
    raise ArgumentError.new unless arr.is_a? Array
    arr.sort!
    size = arr.size
    return arr[0] if size <= 1
    return arr.sum / 2.0 if size == 2
    arr[size / 2]
  end

  def bearings
    {
      N: 0,
      NE: 45,
      E: 90,
      SE: 135,
      S: 180,
      SW: 225,
      W: 270,
      NW: 315
    }.freeze
  end

  def get_bearing(deg)
    deg = (deg + 22.5) % 360
    bearings.each do |k, v|
      return k.to_s if deg.between?(v, v + 45)
    end
  end

  def wind_severity(w)
    return "unknown" if w.nil?
    return "calm" if w <= 2
    return "light" if w <= 5
    return "breezy" if w <= 10
    return "moderate" if w <= 15
    return "strong" if w <= 20
    return "heavy" if w <= 25
    "severe"
  end

  def uv_severity(i)
    return "low" if i <= 2
    return "medium" if i <= 5
    return "high" if i <= 7
    return "very high" if i <= 10
    "extremely high"
  end
end
