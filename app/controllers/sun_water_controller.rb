require 'grid_controller'

class SunWaterController < ApplicationController
  include GridController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def insol_us
    # begin
    #   endpoint = "#{Endpoint::BASE_URL}/insolations/#{Time.now.yesterday.to_date.to_s}"
    #   resp = HTTParty.get(endpoint, { timeout: 10 })
    #   body = JSON.parse(resp.body)
    #   @map_image = "#{Endpoint::HOST}#{body['map']}"
    # rescue Net::ReadTimeout
    #   Rails.logger.error("Timeout on endpoint: #{endpoint}")
    #   @map_image = ""
    # end
    begin
      date = Date.parse(params[:date])
    rescue
      date = (Time.now - 7.hours).to_date.yesterday
    end
    respond_to do |format|
      format.html { insol_image(date) }
      format.csv { send_data insol_csv(date), filename: "insol-values-#{date}.csv" }
    end
  end

  def insol_model
  end

  def et_wimn
    begin
      date = Date.parse(params[:date])
    rescue
      date = (Time.now - 7.hours).to_date.yesterday
    end
    respond_to do |format|
      format.html { et_image(date) }
      format.csv { send_data et_csv(date), filename: "et-values-#{date}.csv" }
    end
  end

  def et_fl
  end

  def et_model
  end

  def spreadsheet_download
  end

  def spreadsheet_doc
  end

  def grid_classes
    @grid_classes = GRID_CLASSES.slice('ET', 'Insol')
  end

  def grid_ets
    @title = 'Download ET Estimates'
    @grid_classes = GRID_CLASSES.slice('ET')
  end

  def grid_insols
    @title = 'Download Insolation Estimates'
    @grid_classes = GRID_CLASSES.slice('Insol')
  end

  private
  def et_image(date)
    grid_ets
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
        data.each do |hash|
          csv << [hash['lat'], hash['long'].to_f * -1.0, hash['value']]
        end
      end
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      return CSV.generate(headers: true)
    end
  end

  def insol_image(date)
    grid_insols
    begin
      endpoint = "#{Endpoint::BASE_URL}/insolations/#{date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      body = JSON.parse(resp.body)
      @map_image = "#{Endpoint::HOST}#{body['map']}"
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
        data.each do |hash|
          csv << [hash['lat'], hash['long'].to_f * -1.0, hash['value']]
        end
      end
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      return CSV.generate(headers: true)
    end
  end
end
