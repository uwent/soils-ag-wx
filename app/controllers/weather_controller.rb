# require "grid_controller"

class WeatherController < ApplicationController
  def index
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

  def weather
    @is_post = request.method == "POST"
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
    @is_post = request.method == "POST"
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

  def et
    @is_post = request.method == "POST"
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
    @is_post = request.method == "POST"
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

  def weather_data
    query = parse_map_params
    @units = params[:units]
    json = AgWeather.get(AgWeather::WEATHER_URL, query:)
    @data = json[:data]

    respond_to do |format|
      format.html { render partial: "weather_data" }
      format.js
      format.csv { send_data to_csv(@data), filename: "Weather data for (#{@lat}, #{@long}) for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.weather_data :: Error: #{e.message}"
    # redirect_to action: :weather
  end

  def precip_data
    query = parse_map_params
    json = AgWeather.get(AgWeather::PRECIP_URL, query:)
    @data = json[:data]

    respond_to do |format|
      format.html { render partial: "precip_data" }
      format.js
      format.csv { send_data to_csv(@data), filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.precip_data :: Error: #{e.message}"
    redirect_to action: :precip
  end

  def et_data
    query = parse_map_params
    json = AgWeather.get(AgWeather::ET_URL, query:)
    @data = json[:data]

    respond_to do |format|
      format.html { render partial: "et_data" }
      format.js
      format.csv { send_data to_csv(@data), filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.et_data :: Error: #{e.message}"
    redirect_to action: :et
  end

  def insol_data
    query = parse_map_params
    json = AgWeather.get(AgWeather::INSOL_URL, query:)
    @data = json[:data]

    respond_to do |format|
      format.html { render partial: "insol_data" }
      format.js
      format.csv { send_data to_csv(@data), filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.insol_data :: Error: #{e.message}"
    redirect_to action: :insol
  end
end
