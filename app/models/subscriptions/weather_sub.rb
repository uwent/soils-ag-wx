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
      total_min_temp = num_fmt(weathers.map { |day| day[:min_temp] }.compact.min) + "°F" || "unknown"
      total_max_temp = num_fmt(weathers.map { |day| day[:max_temp] }.compact.max) + "°F" || "unknown"
      total_precip = num_fmt(precips.map { |day| day[:value] }.compact.sum, 2) + " in" || "unknown"
      total_et = num_fmt(ets.map { |day| day[:value] }.compact.sum, 3) + " in" || "unknown"

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
          totals: {total_min_temp:, total_max_temp:, total_precip:, total_et:}
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
