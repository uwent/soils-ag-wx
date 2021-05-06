module ThermalModelsHelper
  def ddgif_image_link(image_file,alt="Degree-Day Map")
    url =<<-END
    <a href="http://agwx.soils.wisc.edu/soils-agwx-assets/uwex_agwx/images/ddgifs/#{image_file}">
      <IMG SRC="http://agwx.soils.wisc.edu/soils-agwx-assets/uwex_agwx/images/ddgifs/#{image_file}" ALT="#{alt}" height="400" width="480"></a>
      END
    url.html_safe
  end

  def ddgif_url(link_text,image_file)
    link_to link_text, "http://agwx.soils.wisc.edu/soils-agwx-assets/uwex_agwx/images/ddgifs/#{image_file}"
  end

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
end
