class ApplicationController < ActionController::Base
  before_action :set_tab_selected

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
    @map_image = AgWeather.get_map(endpoint: data[:endpoint], query: data[:query])
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
    Time.now.in_time_zone("America/Chicago").yesterday.to_date
  end

  def parse_date
    [Date.parse(params[:date]), default_date].min
  rescue
    default_date
  end

  def get_request_type
    @request_type = request.method
  end

  def try_parse_date(type, default = default_date)
    begin
      # three component date from datepicker
      datesplat = params["#{type}_date_select"]
      return Date.new(*datesplat.values.map(&:to_i)) if datesplat

      # single formatted date
      date = params["#{type}_date"]
      return date.to_date if date
    rescue => e
      Rails.logger.warn "Failed to parse date: #{e.message}"
    end
    default
  end

  def to_csv(data, headers = nil)
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

  # parse a numeric param from a string (truncated at 10 characters)
  # resultant number is rounded to n digits
  def parse_float(str, digits: nil)
    str = str.to_s[0..9]
    return unless /^-?(?:\d+(?:\.\d+)?|\.\d+)$/.match?(str)
    digits ? str.to_f.round(digits) : str.to_f
  end

  def lat
    check_lat(parse_float(params[:lat], digits: 1))
  end

  def long
    check_long(parse_float(params[:long], digits: 1))
  end

  def check_lat(val)
    val.in?(LAT_RANGE) ? val : nil
  end

  def check_long(val)
    val.in?(LONG_RANGE) ? val : nil
  end
end
