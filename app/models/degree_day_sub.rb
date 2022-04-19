class DegreeDaySub < Subscription
  def partial
    "degree_day_data"
  end

  def dates
    Date.current.beginning_of_year..Date.yesterday
  end

  def report_dates
    (dates.last - 2.days)..(dates.last)
  end

  def fetch(sites = self.sites)
    sites = sites.is_a?(Site) ? [sites] : sites

    return unless sites.size > 0

    sites = sites.collect { |site| [site.latitude, site.longitude] }
    all_data = {}

    sites.each do |site|
      lat, long = site
      opts = {
        lat:,
        long:,
        start_date: dates.first,
        end_date: dates.last,
        base: options["base"],
        upper: options["upper"],
        units: options["units"]
      }.compact

      dds = AgWeather.get(AgWeather::DD_URL, query: opts)[:data]

      # collect and format data for each date
      site_data = {}
      report_dates.each do |date|
        dd = dds.find { |h| h[:date] == date.to_s }
        site_data[date.to_s] = {
          date: date_fmt(date),
          min: dd[:min_temp],
          max: dd[:max_temp],
          dd: num_fmt(dd[:value]),
          cum_dd: num_fmt(dd[:cumulative_value])
        }
      end
      all_data[[lat, long].to_s] = site_data
    end
    all_data
  end
end
