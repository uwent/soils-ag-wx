require 'grid_controller'
class SunWaterController < ApplicationController
  include GridController

  before_action :authenticate
  skip_before_action :verify_authenticity_token, only: :get_grid

  def index
  end

  def insol_us
    begin
      endpoint = "#{Endpoint::BASE_URL}/insolations/#{Time.now.yesterday.to_date.to_s}"
      resp = HTTParty.get(endpoint, { timeout: 10 })
      body = JSON.parse(resp.body)
      @map_image = "#{Endpoint::HOST}#{body['map']}"
    rescue Net::ReadTimeout
      Rails.logger.error("Timeout on endpoint: #{endpoint}")
      @map_image = ""
    end
  end

  def insol_model
  end

  def et_wimn
    date = Date.yesterday
    respond_to do |format|
      format.html { et_wimn_image(date) }
      format.csv { send_data et_wimn_csv(date), filename: "et-values-#{date}.csv" }
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
    @grid_classes = GRID_CLASSES.select { |key,val| key == 'ET' }
  end

  def grid_ets
    @title = 'Download ET Estimates'
    @grid_classes = grid_classes
  end

  private
    def et_wimn_image(date)
      @grid_classes = grid_classes
      begin
        endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/#{date}"
        resp = HTTParty.get(endpoint, { timeout: 10 })
        body = JSON.parse(resp.body)
        @map_image = "#{Endpoint::HOST}#{body['map']}"
      rescue Net::ReadTimeout
        Rails.logger.error("Timeout on endpoint: #{endpoint}")
        @map_image = ""
      end
    end

    def et_wimn_csv(date)
      begin
        endpoint = "#{Endpoint::BASE_URL}/evapotranspirations/all_for_date?date=#{date.to_s}"
        resp = HTTParty.get(endpoint, { timeout: 10 })
        body = JSON.parse(resp.body)
        return CSV.generate(headers: true) do |csv|
          csv << %w(Latitude Longitude ET)
          body.each do |hash|
            csv << [hash['lat'], hash['long'].to_f * -1.0, hash['value']]
          end
        end
      rescue Net::ReadTimeout
        Rails.logger.error("Timeout on endpoint: #{endpoint}")
        return CSV.generate(headers: true)
      end
    end
end
