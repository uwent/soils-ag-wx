# require "grid_controller"

class WeatherController < ApplicationController
  before_action :get_request_type

  def index
  end

  def et
    @endpoint = AgWeather::ET_URL
    parse_dates
    @units = params[:units].presence || "in"
    @unit_options = ["in", "mm"]
    @methods = ["classic", "adjusted"]
    @method = params[:method].presence || "classic"

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
    parse_dates
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
    parse_dates
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
    query = parse_map_params
    json = AgWeather.get(AgWeather::ET_URL, query:)
    @data = json[:data]

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
    query = parse_map_params
    json = AgWeather.get(AgWeather::INSOL_URL, query:)
    @data = json[:data]
    if @data
      vals = @data.map { |h| h[:value] }.compact
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
    query = parse_map_params
    @units = params[:units]
    json = AgWeather.get(AgWeather::WEATHER_URL, query:)
    @data = json[:data]
    @cols = %i[min_temp avg_temp max_temp dew_point pressure hours_rh_over_90 avg_temp_rh_over_90]
    if @data
      @totals = {min: {}, avg: {}, max: {}}
      @cols.each do |col|
        vals = @data.map { |data| data[col] }.compact
        @totals[:min][col] = vals.min.round(2)
        @totals[:avg][col] = (vals.sum.to_f / vals.size).round(2)
        @totals[:max][col] = vals.max.round(2)
      end
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
    query = parse_map_params
    json = AgWeather.get(AgWeather::PRECIP_URL, query:)
    @data = json[:data]

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

  # default units from AgWeather:
  # Temp: F
  # Precip: mm, mult by 25.4 => in
  # ET: in, div by 25.4 => mm
  # Insol: mJ, div by 3.6 => kWh
  def site_data
    query = parse_site_params
    @units = params[:units]
    if @units == "metric"
      @units = "C"
      @len_units = "mm"
      @insol_units = "mJ"
      @pres_units = "kPa"
    else
      @units = "F"
      @len_units = "in"
      @insol_units = "kWh"
      @pres_units = "mmHg"
    end

    weather = AgWeather.get_weather(query: query.merge(units: @units))
    precip = AgWeather.get_precip(query:)
    et = AgWeather.get_et(query:)
    insol = AgWeather.get_insol(query:)

    precip_k = (@len_units == "mm") ? 1 : 1 / 25.4
    et_k = (@len_units == "in") ? 1 : 25.4
    insol_k = (@insol_units == "mJ") ? 1 : 1 / 3.6
    pres_k = (@pres_units == "kPa") ? 1 : 7.50062

    if weather.size + precip.size + et.size + insol.size > 0
      # merge data sources by day
      @data = {}
      (@start_date..@end_date).each do |date|
        date = date.to_s
        @data[date] = weather.detect { |k| k[:date] == date } || {}
        @data[date].delete(:date)
        @data[date][:pressure] = @data[date][:pressure]&.* pres_k
        @data[date][:precip] = precip.detect { |k| k[:date] == date }&.dig(:value)&.* precip_k
        @data[date][:et] = et.detect { |k| k[:date] == date }&.dig(:value)&.* et_k
        @data[date][:insol] = insol.detect { |k| k[:date] == date }&.dig(:value)&.* insol_k
      end

      @cols = {
        min_temp: "Min<br>temp<br>(&deg;#{@units})",
        max_temp: "Max<br>temp<br>(&deg;#{@units})",
        avg_temp: "Avg<br>temp<br>(&deg;#{@units})",
        dew_point: "Dew<br>point<br>(&deg;#{@units})",
        precip: "Daily<br>precip.<br>(#{@len_units})",
        et: "Potential<br>ET&nbsp;(#{@len_units})",
        insol: "Insolation<br>(#{@insol_units}/m<sup>2</sup> /day)",
        pressure: "Vap.<br>pres.<br>(#{@pres_units})",
        hours_rh_over_90: "Hours<br>high&nbsp;RH<br>(>90%)",
        # avg_temp_rh_over_90: "Avg<br>temp<br>high&nbsp;RH"
      }.freeze
      summable = %i[precip et insol]

      if @data
        @totals = {min: {}, avg: {}, max: {}, total: {}}
        @cols.keys.each do |col|
          vals = @data.values.map { |data| data[col] }.compact
          @totals[:min][col] = vals.min
          @totals[:avg][col] = (vals.sum.to_f / vals.size)
          @totals[:max][col] = vals.max
          @totals[:total][col] = summable.include?(col) ? vals.sum : nil
        end
      end
    end

    render partial: "data_tbl_combined"
  rescue => e
    Rails.logger.warn "WeatherController.site_data :: Error: #{e.message}"
    @error = e
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

  def get_request_type
    @request_type = request.method
  end

  def parse_map_params
    @lat = params[:latitude].to_f
    @long = params[:longitude].to_f
    @units = params[:units]
    @method = params[:method]
    @start_date = if params[:start_date_select].present?
      Date.new(*params[:start_date_select].values.map(&:to_i))
    else
      params[:start_date]
    end
    @end_date = if params[:end_date_select].present?
      Date.new(*params[:end_date_select].values.map(&:to_i))
    else
      params[:end_date]
    end
    {
      lat: @lat,
      long: @long,
      start_date: @start_date,
      end_date: @end_date,
      units: @units,
      method: @method
    }.compact
  end

  def parse_site_params
    @lat = params[:lat].to_f
    @long = params[:long].to_f
    @start_date = begin
      params[:start_date].to_date
    rescue
      7.days.ago.to_date
    end
    @end_date = begin
      params[:end_date].to_date
    rescue
      Date.yesterday
    end
    {
      lat: @lat,
      long: @long,
      start_date: @start_date,
      end_date: @end_date
    }.compact
  end
end
