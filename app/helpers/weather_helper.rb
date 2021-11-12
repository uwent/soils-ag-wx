module WeatherHelper
  include AgwxGrids
  HYD_ASSET_PATH = "/hyd"

  def c_to_f(c)
    @units == "F" ? c * (5.0 / 9.0) + 32 : c
  rescue
    c
  end

  def sprintf_nilsafe(num, digits)
    num.nil? ? "" : sprintf("%.#{digits}f", num.round(digits))
  rescue
    num
  end


  def latest_hyd_link
    yesterday = 1.days.ago
    link = hyd_link_for(yesterday, "Yesterday's report")
    link == "" ? "Not available." : link
  end

  def hyd_link_for(date, text = date.mday)
    year = date.year
    if date <= Date.today
      link_to text, "#{HYD_ASSET_PATH}/#{year}/#{Hyd.filename(date)}"
    else
      ""
    end
  end

  def td_tag(date = nil)
    if date
      open = if date == Date.today
        "<td bgcolor='#00FFFF' "
      else
        "<td "
      end
      open + "align='center'>" + hyd_link_for(date) + "</td>"
    else
      "<td>&nbsp;</td>"
    end
  end

  def hyd_week(date)
    wday = 0
    res = "<tr>"
    # res += "<td colspan='7'>Incoming: #{date.inspect}</td></tr><tr>"
    # first week in a month, fill in blank days from Sunday
    if date.wday > 0
      (0...date.wday).each { res += td_tag }
      (date.wday..6).each do |ii|
        res += td_tag(date + wday)
        wday += 1
      end
    else
      7.times do |ii|
        if (date + ii).month != date.month
          (ii..6).each { res += td_tag }
          break
        else
          res += td_tag(date + ii)
          wday += 1
        end
      end
    end
    [res + "</tr>", date + wday]
  end

  def hyd_month_row(date)
    <<-END
    <tr><th colspan="7" align="center">#{date.strftime("%B")}</th></tr>
    <tr><th>S</th><th>M</th><th>T</th><th>W</th><th>Th</th><th>F</th><th>Sa</th></tr>
    END
  end

  def hyd_new_month(date)
    <<-END
    </table></td><td style='padding:10px'><table>
    #{hyd_month_row(date)}
    END
  end

  def latitudes
    (38.0..50.0).step(0.1).collect { |lat| [lat.round(1), lat.round(1)] }
  end

  def longitudes
    (-98.0..-82.0).step(0.1).collect { |long| [long.round(1), long.round(1)] }
  end

  def build_map_grid
    s = 1
    lats = (38..50).step(0.5)
    longs = (-98..-82).step(0.5)
    x_start = 50 * s
    x_end = 950 * s
    x_inc = (x_end - x_start) / (longs.count - 1)

    x_start -= 0.5 * x_inc # center the hitbox
    y_start = 50 * s
    y_end = 910 * s
    y_inc = (y_end - y_start) / (lats.count - 1)
    y_start -= 0.5 * y_inc

    # puts "First x: #{x_start} - #{x_start + x_inc}"
    # puts "Last x: #{x_start + x_inc * longs.count} - #{x_start + x_inc * (longs.count + 1)}"
    # puts "First y: #{y_start} - #{y_start + y_inc}"
    # puts "Last y: #{y_start + y_inc * lats.count} - #{y_start + y_inc * (lats.count + 1)}"

    array = []
    row = 0
    lats.reverse_each do |lat|
      col = 0
      longs.each do |long|
        array << {
          lat: lat,
          long: long,
          x1: (x_start + x_inc * col).round(0),
          x2: (x_start + x_inc * (col + 1)).round(0),
          y1: (y_start + y_inc * row).round(0),
          y2: (y_start + y_inc * (row + 1)).round(0)
        }
        col += 1
      end
      row += 1
    end
    array
  end

  def calendar_grid_color(mday, column, today = Date.today)
    if mday == today.mday && column + 1 == today.month
      "aqua"
    elsif (column % 2) == 1
      "yellow"
    else
      "light-grey"
    end
  end

  def webcam_archive_link(thumb, full)
    tts = thumb.timestamp
    fts = full.timestamp
    timg = image_tag("webcam/archive/#{tts.year}/#{sprintf("%02d", tts.month)}/#{sprintf("%02d", tts.day)}/#{thumb.fname}", size: "160x120")
    link_to(
      timg,
      image_path("webcam/archive/#{fts.year}/#{sprintf("%02d", fts.month)}/#{sprintf("%02d", fts.day)}/#{full.fname}")
    )
  end
end
