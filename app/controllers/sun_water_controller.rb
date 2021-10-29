require 'grid_controller'

class SunWaterController < ApplicationController
  include GridController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def insol_map
    begin
      @date = Date.parse(params[:date])
    rescue
      @date = (Time.now - 7.hours).to_date.yesterday
    end
    respond_to do |format|
      format.html { insol_image(@date) }
      format.csv { send_data insol_csv(@date), filename: "insol-values-#{@date}.csv" }
    end
  end

  def et_map
    begin
      @date = Date.parse(params[:date])
    rescue
      @date = (Time.now - 7.hours).to_date.yesterday
    end
    respond_to do |format|
      format.html { et_image(@date) }
      format.csv { send_data et_csv(@date), filename: "et-values-#{@date}.csv" }
    end
  end

  def grid_classes
    @grid_classes = GRID_CLASSES.slice('ET', 'Insol')
  end

  private

  def et_image(date)
    @title = 'Download ET Estimates'
    @grid_classes = GRID_CLASSES.slice('ET')
    begin
      endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/#{date}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      json = JSON.parse(resp.body)
      url = json["map"]
      @map_image = "#{Endpoint::HOST}#{url}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = ""
    end
  end

  def et_csv(date)
    begin
      endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/all_for_date?date=#{date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      json = JSON.parse(resp.body)
      data = json["data"]
      return CSV.generate(headers: true) do |csv|
        csv << %w(Latitude Longitude ET)
        data.each do |h|
          csv << [h["lat"], h["long"], h["value"]]
        end
      end
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      return CSV.generate(headers: true)
    end
  end

  def insol_image(date)
    @title = 'Download Insolation Estimates'
    @grid_classes = GRID_CLASSES.slice('Insol')
    begin
      endpoint = "#{Endpoint::BASE_URL}/insolations/#{date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      body = JSON.parse(resp.body)
      @map_image = "#{Endpoint::HOST}#{body["map"]}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = ""
    end
  end

  def insol_csv(date)
    begin
      endpoint = "#{Endpoint::BASE_URL}/insolations/all_for_date?date=#{date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      json = JSON.parse(resp.body)
      data = json["data"]
      return CSV.generate(headers: true) do |csv|
        csv << %w(Latitude Longitude Insol)
        data.each do |h|
          csv << [h["lat"], h["long"], h["value"]]
        end
      end
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      return CSV.generate(headers: true)
    end
  end
end
