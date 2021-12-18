# require "grid_controller"

class WeatherController < ApplicationController
  include GridController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

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

  def weather_map
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
        send_data to_csv(data), filename: "weather grid for #{@date}.csv"
      }
    end
  end

  def precip_map
    @is_post = request.method == "POST"
    @endpoint = AgWeather::PRECIP_URL
    parse_dates
    @units = params[:units].presence || "mm"
    @unit_options = ["mm", "in"]
    
    respond_to do |format|
      format.html
      format.csv {
        data = AgWeather.get_grid(@endpoint, @date)
        send_data to_csv(data), filename: "precip grid for #{@date}.csv"
      }
    end
  end

  def weather_data
    query = parse_map_params
    @units = params[:units]
    json = AgWeather.get(AgWeather::WEATHER_URL, query: query)
    @data = json[:data]

    respond_to do |format|
      format.js { render layout: false }
      format.csv { send_data to_csv(@data), filename: "Weather data for (#{@lat}, #{@long}) for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.weather_data :: Error: #{e.message}"
    redirect_to action: :weather_map
  end

  def precip_data
    query = parse_map_params
    json = AgWeather.get(AgWeather::PRECIP_URL, query: query)
    @data = json[:data]

    respond_to do |format|
      format.js { render layout: false }
      format.csv { send_data to_csv(@data), filename: "Precip data for #{@lat}, #{@long} for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "WeatherController.precip_data :: Error: #{e.message}"
    redirect_to action: :precip_map
  end

  # def webcam
  # end

  # def webcam_archive
  #   @start_date = Date.today
  #   if params[:date]
  #     begin
  #       @start_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
  #     rescue => e
  #       logger.warn "WeatherController :: error parsing date parameters: '#{params[:date].inspect}', error: #{e.message}"
  #     end
  #   end
  #   @end_date = @start_date + 1 # one day
  #   res = WebcamImage.images_for_date(@start_date)
  #   @thumbs = res[:thumbs]
  #   @fulls = res[:fulls]
  # end
end
