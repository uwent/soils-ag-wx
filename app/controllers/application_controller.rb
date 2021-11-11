class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_tab_selected
  before_action :app_last_updated

  def authenticate
    false
    # For now, pretty lame: We only check that it comes from localhost, redbird, andi, or my static VPN address
    # request.remote_ip == "::1" ||
    #   request.remote_ip == "127.0.0.1" ||
    #   request.remote_ip == "128.104.33.225" ||
    #   request.remote_ip == "128.104.33.224" ||
    #   request.remote_ip == "146.151.214.80"
  end

  def fix_nested_dates(param)
    if param.is_a? String
      # convert to hash
      slen = "start_date".length + 5
      elen = "end_date".length
      start_date_index = param.index("start_date") + slen
      end_date_index = param.index("end_date") + elen
      {
        start_date: param[start_date_index, start_date_index + 10],
        end_date: param[end_date_index, end_date_index + 10]
      }
    else
      param
    end
  end

  private

  def set_tab_selected
    selects = {
      awon: :weather,
      drought: :drought,
      navigation: :about,
      products: :subscriptions,
      subscribers: :subscriptions,
      subscriptions: :subscriptions,
      sun_water: :sun_water,
      thermal_models: :thermal_models,
      weather: :weather
    }
    if params[:controller]
      @tab_selected = {selects[params[:controller].to_sym] => "yes"}
      # "About" is special, we can get that for navigation#about for which we
      # want to select that tab, or anything else we don't want any tab selected
      if @tab_selected[:about]
        if params[:action].to_sym != :about
          @tab_selected = {}
        end
      end
    else
      @tab_selected = {}
    end
  end

  def parse_dates(p)
    # p is e.g. the result from params["grid_date"]
    if p["start_date(1i)"] # it's the old three-element date style
      [
        Date.civil(p["start_date(1i)"].to_i, p["start_date(2i)"].to_i, p["start_date(3i)"].to_i),
        Date.civil(p["end_date(1i)"].to_i, p["end_date(2i)"].to_i, p["end_date(3i)"].to_i)
      ]
    elsif p["start_date"] && p["end_date"]
      [
        Date.parse(p["start_date"]),
        Date.parse(p["end_date"])
      ]
    else
      [nil, nil]
    end
  rescue => e
    Rails.logger.warn "ApplicationController :: Date parsing error: #{e}"
    [nil, nil]
  end

  private

  def app_last_updated
    @app_last_updated = if File.exist?(File.join(Rails.root, "REVISION"))
      File.mtime(File.join(Rails.root, "REVISION")).to_date
    else
      "Unknown"
    end
  end

  def fetch(endpoint)
    response = HTTParty.get(endpoint, timeout: 10)
    JSON.parse(response.body, symbolize_names: true)
  end

  def parse_map_params
    @lat = params[:latitude].to_f
    @long = params[:longitude].to_f
    @start_date = Date.new(*params[:start_date].values.map(&:to_i))
    @end_date = Date.new(*params[:end_date].values.map(&:to_i))
  end

  def parse_date
    Date.parse(params[:date])
  rescue
    (Time.now - 7.hours).to_date.yesterday
  end

  def get_map(url)
    json = fetch(url)
    @map_image = "#{Endpoint::HOST}#{json[:map]}"
  rescue
    Rails.logger.error "Failed to retrieve endpoint: #{url}"
    @map_image = "no_data.png"
  end

  def fetch_to_csv(url)
    json = fetch(url)
    data = json[:data]
    CSV.generate(headers: true) do |csv|
      csv << data.first.keys
      data.each do |h|
        csv << h.values
      end
    end
  rescue
    Rails.logger.error("Failed to retrieve endpoint: #{url}")
    CSV.generate(headers: true)
  end

  def to_csv(data)
    require "csv"
    Rails.logger.info "generating csv"
    CSV.generate(headers: true) do |csv|
      csv << data.first.keys
      data.each do |h|
        csv << h.values
      end
    end
  rescue => e
    Rails.logger.error("Failed to create csv: #{e.message}")
    CSV.generate(headers: true)
  end
end
