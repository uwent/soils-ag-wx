class ThermalModelsController < ApplicationController
  include OakWilt

  # skip_before_action :verify_authenticity_token, only: :get_dds

  def index
  end

  def dd_map
    @dd_submit_text = "Show degree day map"
    @dsv_submit_text = "Show disease risk map"
    @dd_model = params[:dd_model].presence || "dd_50_86"
    @dsv_model = params[:dsv_model].presence || "potato_blight_dsv"
    @map_type = params[:map_type].presence || "dd"
    @endpoint = (@map_type == "dsv") ? AgWeather::PEST_URL : AgWeather::DD_URL
    @model = (@map_type == "dsv") ? @dsv_model : @dd_model
    @start_date = try_parse_date("start", default_date.beginning_of_year)
    @end_date = try_parse_date("end")
    @units = params[:units].presence || "F"
    @min_value = params[:min_value].presence
    @max_value = params[:max_value].presence
    @scale = "#{@min_value},#{@max_value}" if @max_value
    @extent = (params[:wi_only] == "true") ? "wi" : nil

    @opts = {
      start_date: @start_date.to_s,
      end_date: @end_date.to_s,
      model: @model,
      pest: @model,
      units: @units,
      scale: @scale,
      extent: @extent
    }.compact

    respond_to do |format|
      format.html
      # format.csv {
      #   data = AgWeather.get_dd_grid(@model)
      #   send_data to_csv(data), filename: "data grid for #{@model}.csv"
      # }
    end
  end

  def degree_days
    @dd_methods = %w[Average Modified Sine]
    @start_date = default_date.beginning_of_year
  end

  # def get_dds_many_locations
  #   locns_table = locations_for(params[:locations])
  #   min_max_series = {}
  #   @data = locns_table.inject({}) do |data_for_all_locations, (name, coords)|
  #     data_for_all_methods_one_location = params[:method_params].inject({}) do |single_location_data_hash, (key, method_params)|
  #       # Key is the column number in the results table. Might not be sequential if they've deleted some, but it will
  #       # be unique. Each key (e.g. "1") represents one DD accumulation by method, base/upper, and dates for a location.
  #       start_date, end_date = parse_dd_mult_dates method_params
  #       base_temp = (method_params["base_temp"] || "50.0").to_f
  #       upper_temp = (method_params["upper_temp"] || "86.0").to_f # Note that this sets upper for simple and sine, which are ignored
  #       # Fill in the max-mins hash for this location and date range.
  #       fill_in_max_min_series(name, start_date, end_date, coords["longitude"].to_f, coords["latitude"].to_f, min_max_series)
  #       # Now perform the appropriate DD series calc.
  #       dd_series = calc_dd_series_for(
  #         method_params["method"],
  #         start_date, end_date,
  #         coords["longitude"].to_f, coords["latitude"].to_f,
  #         min_max_series[name][start_date.year][:mins], min_max_series[name][start_date.year][:maxes],
  #         base_temp, upper_temp
  #       )
  #       # Use the last date in the accumulation, rather than end_date (might be missing).
  #       last_date = dd_series.keys.max
  #       dd_accum = dd_series[last_date]
  #       # And merge the result into the hash of results
  #       single_location_data_hash.merge({key => {"params" => method_params, "date" => last_date, "data" => dd_accum}})
  #     end
  #     data_for_all_locations.merge({name => data_for_all_methods_one_location})
  #   end
  #   @locations = group_by(locns_table) { |stn| stn["region"] }
  #   # {'DBQ' =>
  #   #   {'1' => { 'params' =>  { 'method' =>  'Simple',  'base_temp' =>  40,  'upper_temp' =>  70},  'date' =>  @end_date,  'data' =>  dd_accum}}
  #   # }
  #   @permalink = permalink(params)
  #   respond_to do |format|
  #     format.html
  #     format.json { render text: @data.to_json }
  #   end
  # end

  def get_dds
    url = AgWeather::DD_URL
    query = parse_dd_params
    json = AgWeather.get(url, query:)
    response = json[:data]
    @data = []

    @param = "#{@method} method DDs#{@base_temp ? " Base temp " + sprintf("%0.1f", @base_temp) : ""}#{@upper_temp ? " Upper temp " + sprintf("%0.1f", @upper_temp) : ""}"

    # make sure each date has a data value
    (@start_date..@end_date).each do |date|
      val = response.detect { |k| k[:date] == date.to_s } || {date: date.to_s}
      @data.push(val)
    end

    @data = @data.last(7) if params[:seven_day]

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@data), filename: "get_dds.csv" }
      format.json do
        render json: {
          params: json[:info],
          data: @data
        }
      end
    end
  rescue => e
    Rails.logger.error "ERROR >> ThermalModel#get_dds: #{e.message}"
    redirect_to action: :degree_days
  end

  # def many_degree_days_for_date
  #   @stations = DegreeDayStation.all
  #   @regions = Region.sort_south_to_north(Region.all)
  # end

  def oak_wilt
    @links = oak_wilt_links
    @units = "F"
  end

  def oak_wilt_dd
    @links = oak_wilt_links
    parse_oak_wilt_dd_params
    query = {
      lat: @latitude,
      lng: @longitude,
      end_date: @end_date,
      start_date: @end_date.beginning_of_year,
      base: 41,
      units: "F"
    }.compact

    json = AgWeather.get_dd(query:)
    @data = json.each do |day|
      day[:risk] = oak_wilt_risk(oak_wilt_scenario(day[:cumulative_value], Date.parse(day[:date])))
    end
    if @data.size > 0
      @scenario = oak_wilt_scenario(@data.last[:cumulative_value], @end_date)
      @risk = oak_wilt_risk(@scenario)
    end
  rescue
    redirect_to action: :oak_wilt
  end

  def potato_data
    @locations = [
      {name: "Rhinelander", lat: 45.7, lng: -89.2},
      {name: "Antigo", lat: 45.2, lng: -89.1},
      {name: "Plover", lat: 44.4, lng: -89.6},
      {name: "Hancock", lat: 44.1, lng: -89.5},
      {name: "Grand Marsh", lat: 43.9, lng: -89.7},
      {name: "Arlington", lat: 43.3, lng: -89.3},
      {name: "Spring Green", lat: 43.2, lng: -90.1}
    ]

    @models = [
      {
        name: "Cumulative late blight disease severity values (DSV) since date:",
        pest: "potato_blight_dsv",
        threshold: 18,
        units: "DSV"
      },
      {
        name: "Cumulative early blight potato physiological days (P-days) since date:",
        pest: "potato_p_days",
        threshold: 300,
        units: "P-days"
      }
    ]

    year = Date.current.year
    emerg_dates = [10, 15, 20, 25].collect { |day| Date.new(year, 5, day) }
    recent_dates = [Date.current - 14.days, Date.current - 7.days]
    dates = emerg_dates + recent_dates
    @dates = emerg_dates.map { |d| d.strftime("%b %-d") } + ["Last 14 days", "Last 7 days"]

    @data = {}

    @models.each do |model|
      mod = model[:pest]
      @data[mod] = {}
      @locations.each do |loc|
        loc_name = loc[:name]
        query = {
          pest: model[:pest],
          lat: loc[:lat],
          lng: loc[:lng],
          start_date: dates.min
        }
        json = AgWeather.get_pest(query:)
        data = json[:data]

        @data[mod][loc_name] = dates.collect do |date|
          if data.size == 0
            -1
          else
            days = data.select { |v| v[:date].to_date >= date }
            value = (days.size > 0) ? days.map { |day| day[:value] }.sum : -1
            value.is_a?(Float) ? value.round(1) : value
          end
        end
      end
    end
    render partial: "potato_data"
  end

  ## PARTIALS ##

  def download_csv
    data = JSON.parse(params[:data], symbolize_names: true)
    respond_to do |format|
      format.csv { send_data to_csv(data), filename: "#{params[:filename]}.csv" }
    end
  end

  private

  def parse_oak_wilt_dd_params
    if params[:lat].present? && params[:lng].present?
      @latitude = lat
      @longitude = lng
    else
      raise ArgumentError.new
    end

    @end_date = try_parse_date("end")
  end

  def parse_dd_map_params
    @model = params[:model].present? ? params[:model] : "dd_50_86"
    @start = try_parse_date(params[:start_date])
    @end = try_parse_date(params[:end_date])
    @units = params[:units] || "F"
  end

  def parse_dd_params
    @latitude = lat
    @longitude = lng
    @start_date = try_parse_date("start", default_date.beginning_of_year)
    @end_date = try_parse_date("end")
    @base_temp = params[:base_temp].to_f
    @upper_temp = ["None", "none", ""].include?(params[:upper_temp]) ? nil : params[:upper_temp].to_f
    @units = params[:units]
    @method = params[:method]
    {
      lat: @latitude,
      lng: @longitude,
      end_date: @end_date,
      start_date: @start_date,
      base: @base_temp,
      upper: @upper_temp,
      units: @units,
      method: @method
    }.compact
  end

  # def set_start_date_end_date(params)
  #   if params[:model_type] === "oak_wilt"
  #     p = params[:grid_date]
  #     @start_date = Date.civil(p["end_date(1i)"].to_i, 1, 1)
  #     @end_date = Date.civil(p["end_date(1i)"].to_i, p["end_date(2i)"].to_i, p["end_date(3i)"].to_i)
  #   else
  #     @start_date, @end_date = parse_dates(params["grid_date"])
  #   end
  # end

  # def locations_for(ids)
  #   ids = ids.collect { |id| id.to_i }
  #   DegreeDayStation.all.select { |stn| ids.include? stn[:id] }.inject({}) { |hash, stn| hash.merge({stn.abbrev => {"longitude" => stn.longitude, "latitude" => stn.latitude, "region" => stn.region}}) }
  # end

  # def format_for(date_param)
  #   # if nil passed in, silently ignore, setting up exception later
  #   if /^\d{2}\/\d{2}\/\d{4}$/.match?((date_param || "")) # It came from the calendar date input
  #     "%m/%d/%Y"
  #   elsif /^\d{2}\/\d{2}$/.match?(date_param) # Just month and year
  #     "%m/%d"
  #   end
  #   # otherwise, silently pass nil back, also setting up exception
  # end

  # def date_for(date_param, default)
  #   if date_param # could just let the rescue clause work, but we'll trade a little code for efficiency
  #     begin
  #       Date.strptime(date_param, format_for(date_param))
  #     rescue => e
  #       logger.warn e.to_s + "\n#{date_param}"
  #       flash[:warning] = "Invalid date #{date_param}"
  #       default
  #     end
  #   else
  #     default
  #   end
  # end

  # parse the incoming start and end dates. If either is missing, use a sensible default (start of year and today). If the
  # year part of the date is missing, fill in with the current year.
  # def parse_dd_mult_dates(p)
  #   [
  #     date_for(p["start_date"], Date.civil(Date.today.year, 1, 1)),
  #     date_for(p["end_date"], Date.today)
  #   ]
  # end

  # Add a level of hierarchy atop the passed-in hash based on a block passed in.
  # So if you pass in {"4" => {:foo => 'bar', :baz => 'blah}, "5" => {:foo => 'bar', :baz => 'zing'}, "6'" => {:foo => 'woof', :baz => 'blah}}
  # and a block of {|thing| thing[:foo]},
  # you should get
  # {
  #    'bar' =>  { "4" => {:foo => 'bar', :baz => 'blah}, "5" => {:foo => 'bar', :baz => 'zing'} },
  #    'woof' => { "6'" => {:foo => 'woof', :baz => 'blah} }
  # }
  # def group_by(hash)
  #   hash.inject({}) do |ret_hash, (key, el)|
  #     group_key = yield el
  #     prev_for_group = ret_hash[group_key] || {}
  #     group = {key => el}.merge(prev_for_group)
  #     ret_hash.merge(group_key => group)
  #   end
  # end

  # For permalinks, strip off a date's year if it's the current year, so that the param always works in future
  # def strip_year_if_current(date_str)
  #   return nil unless date_str && date_str != ""
  #   if date_str =~ /(\d{2}\/\d{2})\/(\d{4})$/ # ends with a year
  #     month_day = $1
  #     year = $2.to_i
  #     return nil if Date.strptime(date_str, "%m/%d/%Y") == Date.today # Don't bother with "today" dates, always default instead
  #     return month_day if year == Date.today.year
  #   end
  #   date_str # Otherwise, just leave it unchanged
  # end

  # Prep a series of incoming parameters so that it's suitable for a permanent bookmark.
  # def permalink(params)
  #   params.delete("authenticity_token")
  #   params.delete("commit")
  #   params.delete("utf8")
  #   params["method_params"].each do |key, m_params|
  #     m_params["start_date"] = strip_year_if_current(m_params["start_date"])
  #     m_params["end_date"] = strip_year_if_current(m_params["end_date"])
  #   end
  #   params
  # end

  # def calc_dd_series_for(method, start_date, end_date, longitude, latitude, mins, maxes, base_temp, upper_temp)
  #   dd_accum = 0.0
  #   data = {}
  #   mins.keys.sort.each do |date|
  #     min = mins[date]
  #     max = maxes[date]
  #     if min.nil? || max.nil?
  #       logger.warn "#{date}, #{longitude}, #{latitude}, #{mins.inspect}, #{maxes[date].inspect}"
  #       raise "cannot continue, nil min or max"
  #     end
  #     min = to_fahrenheit(min)
  #     max = to_fahrenheit(maxes[date])
  #     dd = 0.0
  #     case method
  #     when "Simple"
  #       dd = rect_DD(min, max, base_temp).round
  #     when "Modified"
  #       dd = modB_DD(min, max, base_temp, upper_temp).round
  #     when "Sine"
  #       dd = sine_DD(min, max, base_temp).round
  #     end
  #     dd_accum += dd || 0.0
  #     data[date] = dd_accum
  #   end
  #   data
  # end

  # def fill_in_max_min_series(name, start_date, end_date, longitude, latitude, min_max_series)
  #   # Query out data for the whole year, so it's all there and only has to be done once
  #   start_date = Date.civil(start_date.year, 1, 1)
  #   end_date = Date.civil(end_date.year, 12, 31)
  #   # If we've already retrieved the min/max data for this location and year, don't query it again.
  #   # First make an entry, if necessary, for the location
  #   min_max_series[name] ||= {}
  #   # Then set the year, again if it's not already there.
  #   min_max_series[name][start_date.year] ||= {
  #     mins: WiMnDMinTAir.daily_series(start_date, end_date, longitude, latitude),
  #     maxes: WiMnDMaxTAir.daily_series(start_date, end_date, longitude, latitude)
  #   }
  # end
end
