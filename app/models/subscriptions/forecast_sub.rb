class ForecastSub < WeatherSub
  def partial
    "forecast_data"
  end

  def fetch(sites = self.sites.enabled)
    sites = sites.is_a?(Site) ? [sites] : sites

    return unless sites.size > 0

    sites = sites.collect { |site| [site.latitude, site.longitude] }
    all_data = {}

    sites.each do |site|
      lat, long = site
      response = AgWeather.get(AgWeather::FORECAST_URL, query: {lat:, long:})
      forecasts = response[:forecasts]

      total_min_temp = num_fmt(forecasts.map { |day| day[:temp][:min] }.compact.min) + "°F" || "unknown"
      total_max_temp = num_fmt(forecasts.map { |day| day[:temp][:max] }.compact.max) + "°F" || "unknown"
      total_precip = num_fmt(forecasts.map { |day| day[:rain] / 25.4 }.compact.sum, 2) + " in" || "unknown"
      total_wind = num_fmt(forecasts.map { |day| day[:wind][:max] }.compact.max) + " mph" || "unknown"

      # collect and format data for each date
      site_data = {}
      forecasts.each do |fc|
        datestring = fc[:date]

        min_humidity = fc[:humidity][:min]
        max_humidity = fc[:humidity][:max]
        humidity = min_humidity == max_humidity ? min_humidity : "#{min_humidity} - #{max_humidity}"

        min_wind = num_fmt(fc[:wind][:min], 0)
        max_wind = num_fmt(fc[:wind][:max], 0)
        wind = min_wind == max_wind ? min_wind : "#{min_wind}-#{max_wind}"

        site_data[datestring] = {
          date: date_fmt(Date.parse(fc[:date])),
          min_temp: num_fmt(fc[:temp][:min]),
          max_temp: num_fmt(fc[:temp][:max]),
          humidity:,
          precip: num_fmt(fc[:rain] / 25.4, 2),
          wind: "#{fc[:wind][:bearing]} #{wind}",
          totals: {total_min_temp:, total_max_temp:, total_precip:, total_wind:}
        }
      end

      all_data[[lat, long].to_s] = site_data
    end
    all_data
  rescue
    Rails.logger.error "ForecastSub :: Failed to retrieve data for sites."
    {}
  end
end
