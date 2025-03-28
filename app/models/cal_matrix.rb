require "date"

class CalMatrix
  attr_accessor :cols

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
      col_index + 1
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
end
