class SunWaterController < ApplicationController
  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def et_map
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

  def insol_map
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

  def et_data
    url = AgWeather::ET_URL
    query = parse_map_params
    json = AgWeather.get(url, query:)
    @data = json[:data]

    respond_to do |format|
      format.js
      # format.csv {
      #   send_data to_csv(@data), filename: "ET data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv"
      # }
    end
  rescue => e
    Rails.logger.warn "SunWaterController.et_data :: Error: #{e.message}"
    redirect_to action: :et_map
  end

  def insol_data
    url = AgWeather::INSOL_URL
    query = parse_map_params
    json = AgWeather.get(url, query:)
    @data = json[:data]

    respond_to do |format|
      format.js
      # format.csv {
      #   send_data to_csv(@data), filename: "Insolation data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv"
      # }
    end
  rescue => e
    Rails.logger.warn "SunWaterController.insol_data :: Error: #{e.message}"
    redirect_to action: :insol_map
  end
end
