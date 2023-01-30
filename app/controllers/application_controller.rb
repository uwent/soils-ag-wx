class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_tab_selected

  def authenticate
    request.remote_ip == "127.0.0.1"
    # For now, pretty lame: We only check that it comes from localhost, redbird, andi, or my static VPN address
    # request.remote_ip == "::1" ||
    #   request.remote_ip == "127.0.0.1" ||
    #   request.remote_ip == "128.104.33.225" ||
    #   request.remote_ip == "128.104.33.224" ||
    #   request.remote_ip == "146.151.214.80"
  end

  def reject(error = "error")
    render json: {message: error}, status: 422
  end

  def bad_request
    render json: {message: "Bad request"}, status: :bad_request
  end

  rescue_from ActionController::RoutingError do |e|
    render json: {message: e.message}, status: :bad_request
  end

  def map_image
    data = JSON.parse(request.raw_post, symbolize_names: true)
    @map_image = AgWeather.get_map(data[:endpoint], data[:id], data[:query])
    @caption = data[:caption]
    render partial: "partials/map_image"
  end

  private

  def set_tab_selected
    @tab_selected = {}
    controller = params[:controller]&.to_sym
    action = params[:action]&.to_sym

    @tab_selected = case controller
    when :home
      if action == :index
        {home: "selected"}
      elsif action == :about
        {about: "selected"}
      else
        {}
      end
    when :weather, :awon
      {weather: "selected"}
    when :thermal_models
      {thermal_models: "selected"}
    when :sites
      {sites: "selected"}
    when :subscribers
      {subscribers: "selected"}
    else
      {}
    end
  end

  def default_date
    Time.now.in_time_zone("US/Central").yesterday.to_date
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
      if headers
        headers.each do |line|
          csv << line
        end
        csv << {}
      end
      csv << data.first.keys
      data.each do |h|
        csv << h.values
      end
    end
  rescue => e
    Rails.logger.error "ApplicationController :: Failed to create csv: #{e.message}"
    "no data"
  end

  def get_subscriber_from_session
    @subscriber = Subscriber.find_by(id: session[:subscriber])
    @admin = @subscriber&.admin?
    if @admin && params[:to_edit_id]
      @subscriber = Subscriber.find_by(id: params[:to_edit_id]) || @subscriber
    end
  end

  def validate_lat(lat)
    LAT_RANGE === lat
  end

  def validate_long(long)
    LONG_RANGE === long
  end
end
