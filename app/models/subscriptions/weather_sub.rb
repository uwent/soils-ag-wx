class WeatherSub < Subscription
  def partial
    "weather_data"
  end

  def dates
    (Date.yesterday - 6.days)..Date.yesterday
  end

  def fetch(sites = self.sites.enabled)
    sites = sites.is_a?(Site) ? [sites] : sites

    return unless sites.size > 0

    sites = sites.collect { |site| [site.latitude, site.longitude] }
    all_data = {}

    sites.each do |site|
      lat, long = site
      opts = {
        lat: lat,
        long: long,
        start_date: dates.first,
        end_date: dates.last
      }

      weathers = AgWeather.get(AgWeather::WEATHER_URL, query: opts.merge({units: "F"}))[:data]
      precips = AgWeather.get(AgWeather::PRECIP_URL, query: opts.merge({units: "in"}))[:data]
      ets = AgWeather.get(AgWeather::ET_URL, query: opts)[:data]

      # totals
      total_min_temp = weathers.map { |day| day[:min_temp] }.compact.min
      total_max_temp = weathers.map { |day| day[:max_temp] }.compact.max
      total_precip = precips.map { |day| day[:value] }.compact.sum
      total_et = ets.map { |day| day[:value] }.compact.sum
      total_deficit = total_precip - total_et if total_precip && total_et

      # collect and format data for each date
      site_data = {}
      dates.each do |date|
        datestring = date.to_s
        weather = weathers.find { |h| h[:date] == datestring } || {}
        precip = precips.find { |h| h[:date] == datestring } || {}
        et = ets.find { |h| h[:date] == datestring } || {}
        site_data[datestring] = {
          date: date_fmt(date),
          min_temp: num_fmt(weather[:min_temp]),
          max_temp: num_fmt(weather[:max_temp]),
          precip: num_fmt(precip[:value], 2),
          et: num_fmt(et[:value], 3),
          totals: {
            min_temp: num_fmt(total_min_temp) + "°F" || "unknown",
            max_temp: num_fmt(weathers.map { |day| day[:max_temp] }.compact.max) + "°F" || "unknown",
            precip: num_fmt(precips.map { |day| day[:value] }.compact.sum, 2) + " in." || "unknown",
            et: num_fmt(ets.map { |day| day[:value] }.compact.sum, 2) + " in." || "unknown",
            deficit: num_fmt(total_deficit, 2) + ((total_deficit < 0) ? " in. water deficit" : " in. recharge")
          }
        }
      end

      all_data[[lat, long].to_s] = site_data
    end
    all_data
  rescue
    Rails.logger.error "WeatherSub :: Failed to retrieve data for sites."
    {}
  end
end
