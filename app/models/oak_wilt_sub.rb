
class OakWiltSub < Subscription
  def dates
    Date.current.beginning_of_year..Date.yesterday
  end

  def oak_wilt_scenario(dd_value, date)
    july_15 = Date.new(date.year, 7, 15)
    return "g" if date > july_15 # after jul 15
    return "a" if dd_value < 231 # before flight
    return "b" if dd_value < 368 # 5-25% flight
    return "c" if dd_value < 638 # 25-50% flight
    return "d" if dd_value < 913 # 50-75% flight
    return "e" if dd_value < 2172 # 75-95% flight
    return "f" if dd_value >= 2172 # > 95% flight
    return "a"
  end

  def oak_wilt_risk(scenario)
    case scenario
    when "a"
      "Low - prior to vector emergence"
    when "b"
      "High - early vector flight"
    when "c", "d", "e"
      "High - peak vector flight"
    when "f"
      "High - late vector flight"
    when "g"
      "Low - after July 15"
    end
  end

  def fetch(sites = self.sites)
    sites = sites.is_a?(Site) ? [sites] : sites
    if sites.size > 0
      sites.collect do |site|
        name = site.name
        lat, long = site.latitude, site.longitude
        Rails.logger.debug "\nSite: #{name} (#{lat}, #{long})"

        opts = {
          lat:,
          long:,
          start_date: dates.first,
          end_date: dates.last,
          base: 41,
          units: "F"
          }.compact

        json = AgWeather.get(AgWeather::DD_URL, query: opts)
        data = json[:data].each do |day|
          scenario = oak_wilt_scenario(day[:cumulative_value], Date.parse(day[:date]))
          day[:risk] = oak_wilt_risk(scenario)
        end
        if data.size > 0
          dd = data.last[:cumulative_value]
          scenario = oak_wilt_scenario(dd, dates.last)
          risk = oak_wilt_risk(scenario)
          "#{lat}, #{long}: #{dd} = #{risk}"
        else
          "No data"
        end
      end
    else
      "No sites"
    end
  end
end
