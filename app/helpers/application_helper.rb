module ApplicationHelper
  FROST_COLOR = "blue"
  FREEZE_COLOR = "#c5050c"

  def sprintf_nilsafe(num, digits)
    return "" unless num.is_a? Numeric
    sprintf("%.#{digits}f", num.round(digits))
  end

  def freeze_temp
    (@units == "F") ? 28 : -2.22
  end

  def frost_temp
    (@units == "F") ? 32 : 0
  end

  def format_temp(temp)
    return "" if temp.nil?
    temp_text = sprintf_nilsafe(temp, 1)
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
