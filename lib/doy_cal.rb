#!/usr/local/bin/ruby

require "date"

class CalMatrix
  @cols

  # default to making a calendar for this year
  def initialize(date = Date.today)
    year = date.year
    mon = date.mon
    date = Date.new(year, 1, 1)
    @cols = []
    while year == date.year
      # do one column
      col = []
      @cols[mon - 1] = col
      while mon == date.mon
        col[date.mday - 1] = date.yday.to_s
        date = date.succ
      end
      mon = date.mon
    end
  end

  def col(index)
    @cols[index]
  end

  def row(mday)
    row = []
    0.upto 11 do |col_index|
      col = col(col_index)
      if mday - 1 < col.size
        row[col_index] = col[mday - 1]
      end
      col_index += 1
    end
    row
  end

  def row_to_s(mday)
    row = row(mday)
    row_str = []
    if !row.nil?
      row_index = 0
      row.each do |doy|
        row_str[row_index] = doy.to_s
        row_index += 1
      end
    else
      print("row_to_s: row nil!\n")
    end
    row_str
  end
end # CalMatrix

print("<html><body><table border=\"1\">\n")
months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
0.upto 11 do |mon|
  print("<th>#{months[mon]}</th>")
end
print("\n")

if !ARGV[0].nil?
  year = ARGV[0].to_i
  date = Date.new(year, 1, 1)
else
  date = Date.today
end
cal2 = CalMatrix.new(date)
1.upto 31 do |mday|
  print("<tr>")
  row_str = cal2.row_to_s(mday)
  first = true
  row_str.each do |doy|
    if first
      print("<td><strong>#{doy}</strong></td>")
      first = false
    else
      print("<td>#{doy}</td>")
    end
  end
  print("</tr>\n")
end
0.upto 11 do |mon|
  print("<th>#{months[mon]}</th>")
end
print("\n")
print("</table></body></html>\n")
