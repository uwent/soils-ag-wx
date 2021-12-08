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
    temp_text = sprintf_nilsafe(temp, 2)
    if temp <= freeze_temp
      color = "red"
    elsif temp <= frost_temp
      color = "blue"
    end
    color ? "<span style='color:#{color}'>#{temp_text}</span>" : temp_text
  end
end
