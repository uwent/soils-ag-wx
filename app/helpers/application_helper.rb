module ApplicationHelper
  FROST_COLOR = "blue"
  FREEZE_COLOR = "#c5050c"

  # unit conversions
  def c_to_f(c)
    c * 1.8 + 32.0
  rescue
  end

  def f_to_c(f)
    (f - 32.0) * (5.0 / 9.0)
  rescue
  end

  def in_to_mm(inches)
    inches * 25.4
  rescue
  end

  def mm_to_in(mm)
    mm / 25.4
  rescue
  end

  def mj_to_kwh(mj)
    mj / 3.6
  rescue
  end

  # formatters
  def fmt_num(num, digits = 0)
    return num || "" unless num.is_a? Numeric
    return 0 if num.zero?
    sprintf("%.#{digits}f", num.round(digits))
  end

  def trim_num(num, d = 1)
    f = num.to_f.round(d)
    i = f.to_i
    (f == i) ? i : f
  end

  def fmt_date(datestring)
    date = datestring.to_date
    fmt = (date.year == Date.current.year) ? "%b&nbsp;%-d" : "%b&nbsp;%-d,&nbsp;%Y"
    date.strftime(fmt).html_safe
  rescue
    datestring
  end

  def freeze_temp
    (@units == "F") ? 28 : -2.22
  end

  def frost_temp
    (@units == "F") ? 32 : 0
  end

  def fmt_temp(temp)
    return "" if temp.nil?
    temp_text = fmt_num(temp, 1)
    if temp <= freeze_temp
      color = FREEZE_COLOR
    elsif temp <= frost_temp
      color = FROST_COLOR
    end
    string = color ? "<span style='color: #{color}'>#{temp_text}</span>" : temp_text
    string.html_safe
  end

  def freeze_note
    "Note: Frost temperatures (&lt;#{frost_temp}&deg;#{@units}) shown in <span style='color: #{FROST_COLOR}'>blue</span>, freezing temperatures (&lt;#{freeze_temp}&deg;#{@units}) shown in <span style='color: #{FREEZE_COLOR}'>red</span>.".html_safe
  end

  def fmt_col(col, val)
    case col
    when :min_temp, :avg_temp, :max_temp, :dew_point, :avg_temp_rh_over_90
      fmt_temp(val)
    when :insol
      fmt_num(val, 2)
    when :vapor_pressure, :pressure, :et, :precip
      fmt_num(val, 3)
    else
      fmt_num(val)
    end
  end

  def earliest_date
    Date.new(2016, 1, 1)
  end

  def latitudes
    LAT_RANGE.step(0.1)
  end

  def longitudes
    LONG_RANGE.step(0.1)
  end

  def latitude_labels
    latitudes.collect { |lat| [lat.round(1), lat.round(1)] }
  end

  def longitude_labels
    longitudes.collect { |long| [long.round(1), long.round(1)] }
  end

  def default_latitude
    "43.1"
  end

  def default_longitude
    "-89.4"
  end

  def dd_model_list
    %w[
      dd_32
      dd_38_75
      dd_39p2_86
      dd_41
      dd_41_86
      dd_42p8_86
      dd_45
      dd_45_86
      dd_48
      dd_50
      dd_50_86
      dd_50_90
      dd_52
      dd_55_92
    ].freeze
  end

  # formatted names from dd models
  def dd_models
    models = {}
    dd_model_list.each do |m|
      _, min, max = m.split("_")
      min_f = min.tr("p", ".").to_f
      min_c = trim_num(f_to_c(min_f))
      min_f = trim_num(min_f)
      if max
        max_f = max.tr("p", ".").to_f
        max_c = trim_num(f_to_c(max_f))
        max_f = trim_num(max_f)
        label = "Base #{min_f}°F, upper #{max_f}°F (#{min_c}°C / #{max_c}°C)"
        colname = {
          "F" => "Base #{min_f}°F/#{max_f}°F".html_safe,
          "C" => "Base #{min_c}°C/#{max_c}°C".html_safe
        }
      else
        label = "Base #{min_f}°F (#{min_c}°C)"
        colname = {
          "F" => "Base #{min_f}°F",
          "C" => "Base #{min_c}°C"
        }
      end
      models[m] = {label:, colname:}
    end
    models.freeze
  end

  # array for the dropdown menus
  def dd_labels
    dd_models.collect do |k, v|
      [v[:label], k]
    end.freeze
  end

  def dsv_models
    {
      "potato_blight_dsv" => "Late blight DSVs",
      "potato_p_days" => "Early blight P-Days",
      "carrot_foliar_dsv" => "Carrot foliar disease DSVs",
      "cercospora_div" => "Cercospora leaf spot DSVs",
      "botcast_dsi" => "Botrytis botcast DSIs"
    }
  end

  def dsv_labels
    dsv_models.collect { |k, v| [v, k] }
  end

  def hash_to_text(h)
    str = ""
    h.each do |k, v|
      str << "#{k.to_s.humanize}: #{v}"
      str << "<br>" unless k == h.keys.last
    end
    str
  end
end
