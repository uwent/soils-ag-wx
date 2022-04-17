class WeatherSub < Subscription
  def dates
    (Date.yesterday - 6.days)..Date.yesterday
  end

  def fetch(sites = self.sites.enabled)
    sites = sites.is_a?(Site) ? [sites] : sites

    if sites.size > 0
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

        ets = AgWeather.get(AgWeather::ET_URL, query: opts)[:data]
        precips = AgWeather.get(AgWeather::PRECIP_URL, query: opts.merge({units: "in"}))[:data]
        weathers = AgWeather.get(AgWeather::WEATHER_URL, query: opts.merge({units: "F"}))[:data]

        # collect and format data for each date
        site_data = {}
        dates.each do |date|
          datestring = date.to_formatted_s
          weather = weathers.find { |h| h[:date] == datestring }
          precip = precips.find { |h| h[:date] == datestring }
          et = ets.find { |h| h[:date] == datestring }
          site_data[datestring] = {
            date: date.strftime("%a, %b %-d"),
            min_temp: weather.nil? ? "No data" : sprintf("%.1f", weather[:min_temp]),
            max_temp: weather.nil? ? "No data" : sprintf("%.1f", weather[:max_temp]),
            precip: precip.nil? ? "No data" : sprintf("%.2f", precip[:value]),
            et: et.nil? ? "No data": sprintf("%.3f", et[:value])
          }
        end
        all_data[[lat, long].to_s] = site_data
      end
      all_data
    else
      "No sites"
    end
  end

end
