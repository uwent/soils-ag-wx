class SitesController < ApplicationController
  before_action :get_subscriber_from_session, :get_sites

  def index
  end

  def show
    @lat = lat
    @lng = lng
    @valid = @lat && @lng

    redirect_to(sites_path, alert: "Invalid latitude or longitude provided. Please try again.") if !@valid
    redirect_to(action: :show, lat: @lat, lng: @lng) if params[:etc].present?

    @start_date_opts = start_date_opts
    @start_date = 7.days.ago.to_date
    @end_date = default_date
    @units = (params[:units] == "metric") ? "metric" : "imperial"
    @dd_models = default_dd_models

    if @valid && @subscriber
      @subscriber_site = @sites.where(latitude: @lat, longitude: @lng).first
    end

    common_params = {
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date,
      units: @units
    }
    @weather_params = common_params.merge({action: :site_data_weather})
    @dd_params = common_params.merge({action: :site_data_dd}).merge({dd_models: @dd_models.join(",")})
  rescue => e
    redirect_to sites_path, alert: "Something went wrong: #{e}"
  end

  # Responds to site updates from best_in_place on subscribers/manage
  def update
    return reject("You must be logged in to perform this action.") if @subscriber.nil?
    site = Site.where(id: params[:id]).first
    return reject("This site doesn't belong to you.") unless @subscriber.sites.include?(site) || @admin
    site.update(site_params.compact)
    if site.valid?
      site.save!
      render json: {message: "success"}
    else
      reject(site.errors.full_messages)
    end
  rescue ActiveRecord::RecordNotUnique
    reject("Duplicate site already exists.")
  rescue
    reject("An error occurred white updating the site, please try again.")
  end

  # default units from AgWeather:
  # Temp: F
  # Precip: mm, mult by 25.4 => in
  # ET: in, div by 25.4 => mm
  # Insol: mJ, div by 3.6 => kWh
  def site_data_weather
    @lat = lat
    @lng = lng
    @start_date = try_parse_date("start", 7.days.ago.to_date)
    @end_date = try_parse_date("end")
    @units = params[:units]
    if @units == "metric"
      @units = "C"
      @len_units = "mm"
      @insol_units = "mJ"
      @pres_units = "kPa"
    else
      @units = "F"
      @len_units = "in"
      @insol_units = "kWh"
      @pres_units = "mmHg"
    end

    query = {
      lat: @lat,
      lng: @lng,
      start_date: @start_date,
      end_date: @end_date
    }.compact

    weather = AgWeather.get_weather(query: query.merge(units: @units))
    precip = AgWeather.get_precip(query: query.merge(units: @len_units))
    et = AgWeather.get_et(query: query.merge(units: @len_units))
    insol = AgWeather.get_insol(query: query.merge(units: @insol_units))

    # precip_k = (@len_units == "mm") ? 1.0 : 1 / 25.4
    # et_k = (@len_units == "in") ? 1.0 : 25.4
    # insol_k = (@insol_units == "mJ") ? 1.0 : 1 / 3.6
    pres_k = (@pres_units == "kPa") ? 1.0 : 7.50062

    if weather.size + precip.size + et.size + insol.size > 0
      # merge data sources by day
      @data = {}
      (@start_date..@end_date).each do |date|
        date = date.to_s
        @data[date] = weather.detect { |k| k[:date] == date } || {}
        @data[date].delete(:date)
        @data[date][:vapor_pressure] = @data[date][:vapor_pressure]&.* pres_k
        @data[date][:precip] = precip.detect { |k| k[:date] == date }&.dig(:value)
        @data[date][:et] = et.detect { |k| k[:date] == date }&.dig(:value)
        @data[date][:insol] = insol.detect { |k| k[:date] == date }&.dig(:value)
      end

      @cols = {
        min_temp: "Min<br>temp<br>(&deg;#{@units})",
        max_temp: "Max<br>temp<br>(&deg;#{@units})",
        avg_temp: "Avg<br>temp<br>(&deg;#{@units})",
        dew_point: "Dew<br>point<br>(&deg;#{@units})",
        precip: "Daily<br>precip.<br>(#{@len_units})",
        et: "Potential<br>ET&nbsp;(#{@len_units})",
        insol: "Insolation<br>(#{@insol_units}/m<sup>2</sup> /day)",
        vapor_pressure: "Vap.<br>pres.<br>(#{@pres_units})",
        hours_rh_over_90: "Hours<br>high&nbsp;RH<br>(>90%)"
        # avg_temp_rh_over_90: "Avg<br>temp<br>high&nbsp;RH"
      }.freeze
      summable = %i[precip et insol]

      if @data.present?
        @totals = {min: {}, avg: {}, max: {}, total: {}}
        @cols.keys.each do |col|
          vals = @data.values.map { |data| data[col] }.compact
          @totals[:min][col] = vals.min
          @totals[:avg][col] = (vals.sum.to_f / vals.size)
          @totals[:max][col] = vals.max
          @totals[:total][col] = summable.include?(col) ? vals.sum : nil
        end
      end
    end

    render partial: "data_tbl__weather"
  rescue => e
    Rails.logger.warn "SitesController.site_data_weather :: Error: #{e.message}"
    @error = e
    render partial: "no_data"
  end

  # degree day table
  def site_data_dd
    @lat = lat
    @lng = lng
    @units = (params[:units] == "metric") ? "C" : "F"
    @models = params[:dd_models] || default_dd_models.join(",")
    @end_date = default_date
    @start_date = [try_parse_date("start", 7.days.ago.to_date), @end_date.beginning_of_year].max
    @dates = @start_date..@end_date

    query = {lat: @lat, lng: @lng, units: @units, models: @models}

    response = AgWeather.get_dd_table(query:) # JSON is not symbolized
    info = response["info"] || {}
    @models = info["models"] || []
    data = response["data"] || {}

    if data.size > 0
      @data = data.select { |k, v| @dates === k.to_date }
    end

    render partial: "data_tbl__dd"
  rescue => e
    Rails.logger.warn "SitesController.site_data_dd :: Error: #{e.message}"
    @error = e
    render partial: "no_data"
  end

  private

  def get_sites
    @sites = @subscriber.sites.order(:latitude) if @subscriber
  end

  def site_params
    params.require(:site).permit(:name, :latitude, :longitude)
  end

  def start_date_opts
    {
      "7 days" => 7.days.ago.to_date,
      "2 weeks" => 14.days.ago.to_date,
      "1 month" => 1.month.ago.to_date,
      "1 year" => 1.year.ago.to_date,
      "This year" => Date.current.beginning_of_year
    }.freeze
  end

  def default_dd_models
    [
      "dd_39p2_86",
      "dd_41",
      "dd_42p8_86",
      "dd_50_86",
      "dd_52"
    ].freeze
  end
end
