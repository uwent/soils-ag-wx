module ApplicationHelper
  def sprintf_nilsafe(num, digits)
    num.nil? ? "" : sprintf("%.#{digits}f", num.round(digits))
  rescue
    num
  end

  def c_to_f(c)
    @units == "F" ? c * (9.0 / 5.0) + 32 : c
  rescue
    c
  end

  def freeze_temp
    @units == "F" ? 28 : -2.22
  end

  def frost_temp
    @units == "F" ? 32 : 0
  end

  def format_temp(temp)
    return "" if temp.nil?
    temp_text = sprintf_nilsafe(temp, 1)
    if temp <= freeze_temp
      color = "red"
    elsif temp <= frost_temp
      color = "blue"
    end
    color ? "<span style='color:#{color}'>#{temp_text}</span>" : temp_text
  end

  def earliest_date
    Date.new(2016, 1, 1)
  end

  def latitudes
    (38.0..50.0).step(0.1).collect { |lat| [lat.round(1), lat.round(1)] }
  end

  def default_latitude
    "43.1"
  end

  def longitudes
    (-98.0..-82.0).step(0.1).collect { |long| [long.round(1), long.round(1)] }
  end

  def default_longitude
    "-89.4"
  end
end
