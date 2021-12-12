class SunWaterController < ApplicationController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def et_map
    url = AgWeather::ET_URL
    @date = parse_date()

    respond_to do |format|
      format.html {
        @map_image = AgWeather.get_map(url, @date)
      }
      format.csv {
        data = AgWeather.get_grid(url, @date)
        send_data to_csv(data), filename: "et grid for #{@date}.csv"
      }
    end
  end

  def insol_map
    endpoint = AgWeather::INSOL_URL
    @date = parse_date()

    respond_to do |format|
      format.html {
        @map_image = AgWeather.get_map(endpoint, @date)
      }
      format.csv {
        data = AgWeather.get_grid(endpoint, @date)
        send_data to_csv(data), filename: "insol grid for #{@date}.csv"
      }
    end
  end

  def et_data
    url = AgWeather::ET_URL
    query = parse_map_params()
    json = AgWeather.get(url, query)
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
    query = parse_map_params()
    json = AgWeather.get(url, query)
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
