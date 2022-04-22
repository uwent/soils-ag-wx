module OakWilt
  def oak_wilt_scenario(dd_value, date)
    july_15 = Date.new(date.year, 7, 15)
    return "g" if date > july_15 # after jul 15
    return "a" if dd_value < 231 # before flight
    return "b" if dd_value < 368 # 5-25% flight
    return "c" if dd_value < 638 # 25-50% flight
    return "d" if dd_value < 913 # 50-75% flight
    return "e" if dd_value < 2172 # 75-95% flight
    return "f" if dd_value >= 2172 # > 95% flight
    "a"
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

  def oak_wilt_links
    {
      dnr_page: "https://dnr.wisconsin.gov/topic/foresthealth/oakwilt",
      user_guide: "https://dnr.wisconsin.gov/sites/default/files/topic/ForestHealth/oakWiltVectorsEmergenceUserGuide.pdf",
      video_tutorial: "https://widnr.widen.net/s/6msxrhqvpz/oak-wilt-degree-day-vectors-emergence-user-interface-demo",
      harvesting_guide: "https://widnr.widen.net/view/pdf/aqszuho7ee/Oak-Harvesting-Guidelines-Web-version---FR-560.pdf?t.download=true"
    }
  end
end
