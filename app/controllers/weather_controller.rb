require 'grid_controller'

class WeatherController < ApplicationController
  include GridController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def hyd
    if params[:year]
      @year = params[:year].to_i
    else
      @year = Date.today.year
    end
  end

  def hyd_grid
    date = params[:year] ? Date.civil(params[:year].to_i, 1, 1) : Date.today
    @year = date.year
    render partial: "hyd_grid"
  end

  def awon
  end

  def grid_classes
    @grid_classes = GRID_CLASSES.except('ET', 'Insol')
  end
  
  def grid_temps
    begin
      @date = Date.parse(params[:date])
    rescue
      @date = (Time.now - 7.hours).to_date.yesterday
    end
    respond_to do |format|
      format.html { weather_image(@date) }
      format.csv { send_data weather_csv(@date), filename: "weather data for #{@date}.csv" }
    end
  end
  
  def webcam
  end
  
  def webcam_archive
    @start_date = Date.today
    if params[:date]
      begin
        @start_date = Date.new(params[:date][:year].to_i,params[:date][:month].to_i,params[:date][:day].to_i)
      rescue Exception => e
        logger.warn "error parsing date parameters: '#{params[:date].inspect}'"
      end
    end
    @end_date = @start_date + 1 # one day
    res = WebcamImage.images_for_date(@start_date)
    @thumbs = res[:thumbs]
    @fulls = res[:fulls]
  end
  
  def kinghall
  end
  
  def doycal
    date = params[:year] ? Date.civil(params[:year].to_i,1,1) : Date.today
    @cal_matrix = CalMatrix.new(date)
    @year = date.year
  end
  
  def doycal_grid
    date = params[:year] ? Date.civil(params[:year].to_i,1,1) : Date.today
    @cal_matrix = CalMatrix.new(date)
    @year = date.year
    render partial: "doycal_grid"
  end

  private
  def weather_image(date)
    grid_classes
    begin
      endpoint = "#{Endpoint::BASE_URL}/weather/#{date}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      json = JSON.parse(resp.body)
      url = json["map"]
      @map_image = "#{Endpoint::HOST}#{url}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = "no_data.png"
    end
  end

  def weather_csv(date)
    begin
      endpoint = "#{Endpoint::BASE_URL}/weather/all_for_date?date=#{date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      json = JSON.parse(resp.body, symbolize_names: true)
      data = json[:data]
      return CSV.generate(headers: true) do |csv|
        csv << data.first.keys
        data.each do |h|
          csv << h.values
        end
      end
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      return CSV.generate(headers: true)
    end
  end
  
end
