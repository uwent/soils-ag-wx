# require "grid_controller"

class WeatherController < ApplicationController
  before_action :get_request_type

  def index
  end

  def et
    @endpoint = AgWeather::ET_URL
    parse_cumulative_params
    @units = params[:units].presence || "in"
    @unit_options = ["in", "mm"]
    @et_methods = ["classic", "adjusted"]
    @et_method = params[:et_method].presence || "classic"

    respond_to do |format|
      format.html
      format.csv {
        data = AgWeather.get_grid(@endpoint, @date)
        send_data to_csv(data), filename: "et grid (in) for #{@date}.csv"
      }
    end
  end

  def insol
    @endpoint = AgWeather::INSOL_URL
    parse_cumulative_params
    @units = params[:units].presence || "MJ"
    @unit_options = ["MJ", "KWh"]

    respond_to do |format|
      format.html
      format.csv {
        data = AgWeather.get_grid(@endpoint, @date)
        send_data to_csv(data), filename: "insol grid (mj-m2-day) for #{@date}.csv"
      }
    end
  end

  def weather
    @endpoint = AgWeather::WEATHER_URL
    @date = parse_date
    @units = params[:units].presence || "F"
    @unit_options = ["F", "C"]
    @temp_selector = true

    respond_to do |format|
      format.html
      format.csv {
        data = AgWeather.get_grid(@endpoint, @date)
        headers = {
          "Temperature units: #{@units}": nil,
          "Vapor pressure units: kPa": nil
        }
        send_data to_csv(data, headers:), filename: "weather grid for #{@date}.csv"
      }
    end
  end

  def precip
    @endpoint = AgWeather::PRECIP_URL
    parse_cumulative_params
    @units = params[:units].presence || "in"
    @unit_options = ["mm", "in"]

    respond_to do |format|
      format.html
      format.csv {
        data = AgWeather.get_grid(@endpoint, @date)
        send_data to_csv(data), filename: "precip grid for #{@date}.csv"
      }
    end
  end

  def et_data
    @et_method = params[:et_method]
    query = parse_data_params.merge(method: @et_method)
    response = AgWeather.get_et(query:)
    @data = []

    # make sure each date has a data value
    (@start_date..@end_date).each do |date|
      val = response.detect { |k| k[:date] == date.to_s } || {date: date.to_s}
      @data.push(val)
    end

    respond_to do |format|
      format.html { render partial: (@data.length > 0) ? "data_tbl_et" : "no_data" }
      format.js
      format.csv {
        send_data(
          to_csv(@data),
          filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv"
        )
      }
    end
  rescue => e
    Rails.logger.warn "WeatherController.et_data :: Error: #{e.message}"
    render partial: "no_data"
  end

  def insol_data
    query = parse_data_params
    response = AgWeather.get_insol(query:)
    @data = []

    # make sure each date has a data value
    (@start_date..@end_date).each do |date|
      val = response.detect { |k| k[:date] == date.to_s } || {date: date.to_s}
      @data.push(val)
    end

    # calculate totals
    vals = @data.map { |h| h[:value] }.compact
    if vals.size > 0
      sum = vals.sum.to_f
      @totals = {
        "Min daily" => vals.min,
        "Avg daily" => (sum / vals.size),
        "Max daily" => vals.max,
        "Total" => sum
      }
    end

    respond_to do |format|
      format.html { render partial: (@data.length > 0) ? "data_tbl_insol" : "no_data" }
      format.js
      format.csv {
        send_data(
          to_csv(@data),
          filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv"
        )
      }
    end
  rescue => e
    Rails.logger.warn "WeatherController.insol_data :: Error: #{e.message}"
    render partial: "no_data"
  end

  def weather_data
    @units = params[:units]
    query = parse_data_params.merge(units: @units)
    response = AgWeather.get_weather(query:)
    @cols = %i[min_temp avg_temp max_temp dew_point vapor_pressure hours_rh_over_90 avg_temp_rh_over_90]
    @data = []

    # make sure each date has a data value
    (@start_date..@end_date).each do |date|
      val = response.detect { |k| k[:date] == date.to_s } || {date: date.to_s}
      @data.push(val)
    end

    # calculate totals
    @totals = {min: {}, avg: {}, max: {}}
    @cols.each do |col|
      vals = @data.map { |data| data[col] }.compact || []
      next if vals.size == 0
      @totals[:min][col] = vals.min.round(2)
      @totals[:avg][col] = (vals.sum.to_f / vals.size).round(2)
      @totals[:max][col] = vals.max.round(2)
    end

    respond_to do |format|
      format.html { render partial: (@data.length > 0) ? "data_tbl_weather" : "no_data" }
      format.js
      format.csv {
        send_data(
          to_csv(@data),
          filename: "Weather data for (#{@lat}, #{@long}) for dates #{@start_date} to #{@end_date}.csv"
        )
      }
    end
  rescue => e
    Rails.logger.warn "WeatherController.weather_data :: Error: #{e.message}"
    render partial: "no_data"
  end

  def precip_data
    query = parse_data_params
    query[:units] = "mm"
    response = AgWeather.get_precip(query:)
    @data = []

    # make sure each date has a data value
    (@start_date..@end_date).each do |date|
      val = response.detect { |k| k[:date] == date.to_s } || {date: date.to_s}
      @data.push(val)
    end

    respond_to do |format|
      format.html { render partial: (@data.length > 0) ? "data_tbl_precip" : "no_data" }
      format.js
      format.csv {
        send_data(
          to_csv(@data),
          filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv"
        )
      }
    end
  rescue => e
    Rails.logger.warn "WeatherController.precip_data :: Error: #{e.message}"
    render partial: "no_data"
  end

  def doycal
    date = params[:year] ? Date.civil(params[:year].to_i, 1, 1) : Date.today
    @cal_matrix = CalMatrix.new(date)
    @year = date.year
  end

  def doycal_grid
    date = params[:year] ? Date.civil(params[:year].to_i, 1, 1) : Date.today
    @cal_matrix = CalMatrix.new(date)
    @year = date.year
    render partial: "doycal_grid"
  end

  def hyd
    @year = if params[:year]
      params[:year].to_i
    else
      Date.today.year
    end
  end

  def hyd_grid
    date = params[:year] ? Date.civil(params[:year].to_i, 1, 1) : Date.today
    @year = date.year
    render partial: "hyd_grid"
  end

  private

  def parse_data_params
    @lat = lat
    @long = long
    @start_date = try_parse_date("start", 7.days.ago.to_date)
    @end_date = try_parse_date("end")
    {
      lat: @lat,
      long: @long,
      start_date: @start_date,
      end_date: @end_date
    }.compact
  end

  def parse_cumulative_params
    if params[:cumulative]
      @cumulative = true
      @start_date = try_parse_date("start", default_date.beginning_of_year)
      @end_date = try_parse_date("end")
      @date = @end_date
    else
      @date = parse_date
    end
  end
end
