module ThermalModelsHelper

  # oak wilt scenarios
  def define_scenario(dd_value, end_date)
    july_15 = (end_date.year.to_s + "-07-15").to_date
    return "scenario_g" if end_date > july_15 # after jul 15
    return "scenario_a" if dd_value < 231 # before flight
    return "scenario_b" if dd_value < 368 # 5-25% flight
    return "scenario_c" if dd_value < 638 # 25-50% flight
    return "scenario_d" if dd_value < 913 # 50-75% flight
    return "scenario_e" if dd_value < 2172 # 75-95% flight
    return "scenario_f" if dd_value >= 2172 # > 95% flight
    return "scenario_a"
  end

  def scenario_risk(scenario)
    case scenario
    when "a"
      "low - prior to vector emergence"
    when "b"
      "moderate - early vector flight"
    when "c", "d"
      "high - peak vector flight"
    when "e"
      "moderate - late vector flight"
    when "f"
      "low - after vector flights"
    when "g"
      "low - after July 15"
    end
  end
end
