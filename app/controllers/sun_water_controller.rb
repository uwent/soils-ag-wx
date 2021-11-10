require "grid_controller"

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

  def insol_data
    @lat = params[:latitude].to_f
    @long = params[:longitude].to_f
    @start_date = Date.new(*params[:start_date].values.map(&:to_i))
    @end_date = Date.new(*params[:end_date].values.map(&:to_i))

    url = "#{Endpoint::INSOL_URL}?lat=#{@lat}&long=#{@long}&start_date=#{@start_date}&end_date=#{@end_date}"
    response = HTTParty.get(url, {timeout: 5})
    json = JSON.parse(response.body, symbolize_names: true)
    @data = json[:data]
    Rails.logger.info "SunWaterController.insol_data :: Got et data!"

    respond_to do |format|
      format.js { render layout: false }
      format.csv { send_data to_csv(@data), filename: "Insolation data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "SunWaterController.insol_data :: Error: #{e.message}"
    redirect_to action: :insol_map
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

  def et_data
    @lat = params[:latitude].to_f
    @long = params[:longitude].to_f
    @start_date = Date.new(*params[:start_date].values.map(&:to_i))
    @end_date = Date.new(*params[:end_date].values.map(&:to_i))

    url = "#{Endpoint::ET_URL}?lat=#{@lat}&long=#{@long}&start_date=#{@start_date}&end_date=#{@end_date}"
    response = HTTParty.get(url, {timeout: 5})
    json = JSON.parse(response.body, symbolize_names: true)
    @data = json[:data]
    Rails.logger.info "SunWaterController.et_data :: Got et data!"

    respond_to do |format|
      format.js { render layout: false }
      format.csv { send_data to_csv(@data), filename: "ET data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "SunWaterController.et_data :: Error: #{e.message}"
    redirect_to action: :et_map
  end

  def grid_classes
    @grid_classes = GRID_CLASSES.slice("ET", "Insol")
  end

  private

  def et_image(date)
    @title = "Download ET Estimates"
    @grid_classes = GRID_CLASSES.slice("ET")
    begin
      endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/#{date}"
      resp = HTTParty.get(endpoint, {timeout: 10})
      json = JSON.parse(resp.body)
      url = json["map"]
      @map_image = "#{Endpoint::HOST}#{url}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = ""
    end
  end

  def et_csv(date)
    endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/all_for_date?date=#{date}"
    resp = HTTParty.get(endpoint, {timeout: 10})
    json = JSON.parse(resp.body)
    data = json["data"]
    CSV.generate(headers: true) do |csv|
      csv << %w[Latitude Longitude ET]
      data.each do |h|
        csv << [h["lat"], h["long"], h["value"]]
      end
    end
  rescue Net::ReadTimeout
    Rails.logger.error("Timeout on endpoint: #{endpoint}")
    CSV.generate(headers: true)
  end

  def insol_image(date)
    @title = "Download Insolation Estimates"
    @grid_classes = GRID_CLASSES.slice("Insol")
    begin
      endpoint = "#{Endpoint::BASE_URL}/insolations/#{date}"
      resp = HTTParty.get(endpoint, {timeout: 10})
      body = JSON.parse(resp.body)
      @map_image = "#{Endpoint::HOST}#{body["map"]}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = ""
    end
  end

  def insol_csv(date)
    endpoint = "#{Endpoint::BASE_URL}/insolations/all_for_date?date=#{date}"
    resp = HTTParty.get(endpoint, {timeout: 10})
    json = JSON.parse(resp.body)
    data = json["data"]
    CSV.generate(headers: true) do |csv|
      csv << %w[Latitude Longitude Insol]
      data.each do |h|
        csv << [h["lat"], h["long"], h["value"]]
      end
    end
  rescue Net::ReadTimeout
    Rails.logger.error("Timeout on endpoint: #{endpoint}")
    CSV.generate(headers: true)
  end
end
