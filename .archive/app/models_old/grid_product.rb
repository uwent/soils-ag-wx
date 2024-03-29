# Monkey-patch Numeric so we can easily round to nearest appropriate fraction of a degree
# Modified 2014-04-25: Always return 'd' digits
# Thanks to http://pullmonkey.com/2008/1/31/rounding-to-the-nearest-number-in-ruby/

class Numeric
  def rdup(nearest = 10, d = 1)
    (self % nearest == 0) ? round(d) : (self + nearest - (self % nearest)).round(d)
  end

  def rddown(nearest = 10, d = 1)
    (self % nearest == 0) ? round(d) : (self - (self % nearest)).round(d)
  end

  def rdnearest(nearest = 10, d = 1)
    (((rdup(nearest) - self).abs) < ((self - rddown(nearest)).abs)) ? rdup(nearest, d) : rddown(nearest, d)
  end
end

class GridProduct < Product
  # Return the set of query values for date and time appropriate to this kind of grid.
  # Default to 1 week ago through today
  def self.query_dt_values(start_timestamp, finish_timestamp)
    start_timestamp ||= 1.week.ago
    finish_timestamp ||= Time.now
    [
      start_timestamp.strftime("%Y-%m-%d"),
      nil,
      finish_timestamp.strftime("%Y-%m-%d"),
      nil
    ]
  end

  def self.long_col(longitude)
    "w" + (10 * longitude.rdnearest(0.4)).to_i.abs.to_s
  end

  def series_with_dates(latitude, longitude, start_timestamp = nil, finish_timestamp = nil)
    c = self.class
    query_lat = latitude.rdnearest(0.4)
    start_ds, _start_ts, finish_ds, _finish_ts = GridProduct.query_dt_values(start_timestamp, finish_timestamp)
    query = "select date,#{c.long_col(longitude)} as value from #{data_table_name} \
    where date >= '#{start_ds}' and date <= '#{finish_ds}' and latitude=#{query_lat} order by date"
    (self.class.find_by_sql query).map { |e| {e[:date] => e[:value]} }
  end

  def series(latitude, longitude, start_timestamp = nil, finish_timestamp = nil)
    c = self.class
    query_lat = latitude.rdnearest(0.4)
    start_ds, _start_ts, finish_ds, _finish_ts = GridProduct.query_dt_values(start_timestamp, finish_timestamp)
    query = "select #{c.long_col(longitude)} as value from #{data_table_name} \
    where date >= '#{start_ds}' and date <= '#{finish_ds}' and latitude=#{query_lat} order by date"
    (self.class.find_by_sql query).map { |e| e[:value] }
  end

  def monthly_sums(latitude, longitude, start_timestamp, finish_timestamp)
    ser = series_with_dates(latitude, longitude, start_timestamp, finish_timestamp)
    ret = []
    sum = 0.0
    date = nil
    cur = start_timestamp
    ser.each do |el|
      date_str = el.keys.first
      date = Date.parse(date_str)
      if date.month == cur.month
        sum += el[date_str].to_f
      else
        ret << [Date.new(cur.year, cur.month, 1), sum]
        sum = el[date_str].to_f
        cur = date
      end
    end
    if cur != date # we didn't finish a month and put its summary into the table; usually true
      ret << [Date.new(cur.year, cur.month, 1), sum]
    end
    ret
  end
end
