class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_tab_selected
  before_action :app_last_updated

  def authenticate
    request.remote_ip == "127.0.0.1"
    # For now, pretty lame: We only check that it comes from localhost, redbird, andi, or my static VPN address
    # request.remote_ip == "::1" ||
    #   request.remote_ip == "127.0.0.1" ||
    #   request.remote_ip == "128.104.33.225" ||
    #   request.remote_ip == "128.104.33.224" ||
    #   request.remote_ip == "146.151.214.80"
  end

  # def fix_nested_dates(param)
  #   if param.is_a? String
  #     # convert to hash
  #     slen = "start_date".length + 5
  #     elen = "end_date".length
  #     start_date_index = param.index("start_date") + slen
  #     end_date_index = param.index("end_date") + elen
  #     {
  #       start_date: param[start_date_index, start_date_index + 10],
  #       end_date: param[end_date_index, end_date_index + 10]
  #     }
  #   else
  #     param
  #   end
  # end

  def bad_request
    render json: {error: "Bad request"}, status: :bad_request
  end

  rescue_from ActionController::RoutingError do |e|
    render json: {error: e.message}, status: :bad_request
  end

  def map_image
    data = JSON.parse(request.raw_post, symbolize_names: true)
    @map_image = AgWeather.get_map(data[:endpoint], data[:id], data[:query])
    render partial: "partials/map_image"
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

  # def parse_dates(p)
  #   # p is e.g. the result from params["grid_date"]
  #   if p["start_date(1i)"] # it's the old three-element date style
  #     [
  #       Date.civil(p["start_date(1i)"].to_i, p["start_date(2i)"].to_i, p["start_date(3i)"].to_i),
  #       Date.civil(p["end_date(1i)"].to_i, p["end_date(2i)"].to_i, p["end_date(3i)"].to_i)
  #     ]
  #   elsif p["start_date"] && p["end_date"]
  #     [
  #       Date.parse(p["start_date"]),
  #       Date.parse(p["end_date"])
  #     ]
  #   else
  #     [nil, nil]
  #   end
  # rescue => e
  #   Rails.logger.warn "ApplicationController :: Date parsing error: #{e}"
  #   [nil, nil]
  # end

  def app_last_updated
    @app_last_updated = if File.exist?(File.join(Rails.root, "REVISION"))
      File.mtime(File.join(Rails.root, "REVISION")).to_date
    else
      "Unknown"
    end
  end

  # def fetch(endpoint)
  #   response = HTTParty.get(endpoint, timeout: 10)
  #   JSON.parse(response.body, symbolize_names: true)
  # end

  def default_date
    Time.now.in_time_zone("US/Central").yesterday.to_date
  end

  def parse_map_params
    @lat = params[:latitude].to_f
    @long = params[:longitude].to_f
    @start_date = Date.new(*params[:start_date_select].values.map(&:to_i))
    @end_date = Date.new(*params[:end_date_select].values.map(&:to_i))
    @units = params[:units]
    @method = params[:method]
    {
      lat: @lat,
      long: @long,
      start_date: @start_date,
      end_date: @end_date,
      units: @units,
      method: @method
    }.compact
  end

  def parse_date
    [Date.parse(params[:date]), default_date].min
  rescue
    default_date
  end

  def parse_dates
    if params[:cumulative]
      @cumulative = true
      start_date = Date.new(*params[:start_date_select].values.map(&:to_i)) || default_date.beginning_of_year
      date = Date.new(*params[:end_date_select].values.map(&:to_i)) || default_date
      @date = [date, default_date].min
      @start_date = [start_date, @date].min
    else
      @date = parse_date
    end
  rescue
    @date = parse_date
  end

  def to_csv(data, headers: nil)
    require "csv"
    Rails.logger.debug "ApplicationController :: Generating csv..."
    CSV.generate(headers: true) do |csv|
      headers.each do |line|
        csv << line
      end
      csv << {} if headers

      csv << data.first.keys
      data.each do |h|
        csv << h.values
      end
    end
  rescue => e
    Rails.logger.error "ApplicationController :: Failed to create csv: #{e.message}"
    "no data"
  end
end
