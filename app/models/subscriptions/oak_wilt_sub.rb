class OakWiltSub < PestSub
  include OakWilt

  def partial
    "oak_wilt_data"
  end

  def dates
    Date.current.beginning_of_year..Date.yesterday
  end

  def fetch(sites = self.sites.enabled)
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
        base: 41,
        units: "F"
      }

      data = AgWeather.get(AgWeather::DD_URL, query: opts)[:data]

      # collect and format data for each date
      # The API should not send nil data so the last date in the return should have data though it may not be the present date
      today = Date.parse(data.last[:date])
      dd = data.last[:cumulative_value]
      last_7 = data.last(7).map { |day| day[:value] }.compact
      last_7_avg = last_7.sum / last_7.count
      i = 0

      site_data = {}
      (today..(today + 6.days)).each do |date|
        proj_dd = (dd + last_7_avg * i).round(1)
        scenario = oak_wilt_scenario(proj_dd, date)
        risk = oak_wilt_risk(scenario)
        site_data[date.to_s] = {
          date: date_fmt(date),
          cum_dd: num_fmt(proj_dd),
          risk:,
        }
        i += 1
      end
      all_data[[lat, long].to_s] = site_data
    end
    all_data
  rescue
    Rails.logger.error "OakWiltSub :: Failed to retrieve data for sites."
    {}
  end
end
