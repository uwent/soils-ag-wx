class SunWaterController < ApplicationController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def et_map
    @date = parse_date
    respond_to do |format|
      format.html {
        url = "#{Endpoint::ET_URL}/#{@date}"
        get_map(url)
      }
      format.csv {
        url = "#{Endpoint::ET_URL}/all_for_date?date=#{@date}"
        send_data fetch_to_csv(url), filename: "et grid for #{@date}.csv"
      }
    end
  end

  def insol_map
    @date = parse_date
    respond_to do |format|
      format.html {
        url = "#{Endpoint::INSOL_URL}/#{@date}"
        get_map(url)
      }
      format.csv {
        url = "#{Endpoint::INSOL_URL}/all_for_date?date=#{@date}"
        send_data fetch_to_csv(url), filename: "insol grid #{@date}.csv"
      }
    end
  end

  def et_data
    parse_map_params

    endpoint = "#{Endpoint::ET_URL}?lat=#{@lat}&long=#{@long}&start_date=#{@start_date}&end_date=#{@end_date}"
    json = fetch(endpoint)
    @data = json[:data]
    # @csv = to_csv(@data)
    # @csv_name = "ET data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv"

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
    parse_map_params

    endpoint = "#{Endpoint::INSOL_URL}?lat=#{@lat}&long=#{@long}&start_date=#{@start_date}&end_date=#{@end_date}"
    json = fetch(endpoint)
    @data = json[:data]

    respond_to do |format|
      format.js
      # format.csv { send_data to_csv(@data), filename: "Insolation data for (#{@lat},#{@long}) for dates #{@start_date} to #{@end_date}.csv" }
    end
  rescue => e
    Rails.logger.warn "SunWaterController.insol_data :: Error: #{e.message}"
    redirect_to action: :insol_map
  end

end
