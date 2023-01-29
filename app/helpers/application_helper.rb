module ApplicationHelper
  FROST_COLOR = "blue"
  FREEZE_COLOR = "#c5050c"

  def fmt_num(num, digits = 0)
    return num || "" unless num.is_a? Numeric
    sprintf("%.#{digits}f", num.round(digits))
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
    when :pressure, :et, :precip
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
end
