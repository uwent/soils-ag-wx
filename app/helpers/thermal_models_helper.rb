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
    date_string = end_date.year.to_s + "-07-15"
    july_15 = date_string.to_date
    case
    when dd_value < 128.3 && end_date <= july_15 then return "scenario_a"
    when 215.8 > dd_value && dd_value >= 128.3 && end_date <= july_15 then "scenario_b"
    when 354.2 > dd_value && dd_value >= 215.8 && end_date <= july_15 then "scenario_c"
    when 507.2 > dd_value && dd_value >= 354.2 && end_date <= july_15 then "scenario_d"
    when 1206.7 > dd_value && dd_value >= 507.2 && end_date <= july_15 then "scenario_e"
    when dd_value >= 1206.7 && end_date <= july_15 then "scenario_f"
    when end_date > july_15 then "scenario_g"
    end
  end
end
