class DegreeDaySub < Subscription
  def dates
    Date.current.beginning_of_year..Date.yesterday
  end

  def fetch(sites = self.sites)
    Rails.logger.debug "Fetching #{name}"

    sites = sites.is_a?(Site) ? [sites] : sites

    if sites.size > 0
      sites.collect do |site|
        lat, long = site.latitude, site.longitude
        Rails.logger.debug "\nSite: #{site.name} (#{lat}, #{long})"

        opts = {
          lat:,
          long:,
          start_date: dates.first,
          end_date: dates.last,
          base: options[:base],
          upper: options[:upper],
          units: options[:units]
        }.compact

        data = AgWeather.get(AgWeather::DD_URL, query: opts)[:data]
        if data.size > 0
          dd = data.last[:cumulative_value]
          "#{lat}, #{long}: #{name} = #{dd}"
        else
          "No data"
        end
      end
    else
      "No sites"
    end
  end
end
