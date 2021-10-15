require 'grid_controller'

class WeatherController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:get_grid]
  
  include GridController

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
    @grid_classes = grid_classes
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
  
end
