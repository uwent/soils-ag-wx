
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
    Rails.logger.debug "Fetching Oak Wilt subscription data for #{sites.size} sites..."
    if sites.size > 0
      all_data = {}
      sites.each do |site|
        name = site.name
        lat, long = site.latitude, site.longitude
        Rails.logger.debug "Site: #{name} (#{lat}, #{long})"

        opts = {
          lat:,
          long:,
          start_date: dates.first,
          end_date: dates.last,
          base: 41,
          units: "F"
        }

        json = AgWeather.get(AgWeather::DD_URL, query: opts)
        data = json[:data]
        if data.size > 0
          today = Date.parse(data.last[:date])
          dd = data.last[:cumulative_value]
          last_7 = data.last(7).map { |day| day[:value] }.compact
          last_7_avg = last_7.sum / last_7.count
          i = 0
          site_data = (today..(today + 6.days)).collect do |date|
            proj_dd = (dd + last_7_avg * i).round(1)
            hash = {
              date: date,
              dd: proj_dd,
              risk: oak_wilt_risk(oak_wilt_scenario(proj_dd, date))
            }
            i += 1
            hash
          end
          all_data[[lat, long].to_s] = site_data
        end
      end
      all_data
    else
      "No sites"
    end
  end
end
