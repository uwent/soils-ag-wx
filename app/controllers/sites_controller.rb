class SitesController < ApplicationController
  before_action :get_subscriber_from_session, :get_sites

  def index
  end

  def show
    if params[:lat] && params[:long]
      @lat = params[:lat].to_f.round(1)
      @long = params[:long].to_f.round(1)
      @valid = validate_lat(@lat) && validate_long(@long)
      if @valid && params[:etc].present?
        redirect_to(action: :show, lat: @lat, long: @long)
      end
    end

    @title = (@lat && @long && @valid) ? "Recent data for #{@lat}&deg;N, #{@long}&deg;W".html_safe : "Site data"
    @welcome_image = "awon.png"
    if @valid && @subscriber
      @subscriber_site = @sites.where(latitude: @lat, longitude: @long).first
    end
  end

  def update
    return reject("Must be logged in.") if @subscriber.nil? || !@subscriber.admin?
    site = Site.find(params[:id])
    return reject("This site doesn't belong to you.") unless @subscriber.sites.include? site
    site.update!(site_params.compact)
    render json: {message: "success"}
  rescue => e
    render json: {message: e}, status: 422
  end

  private

  def get_sites
    @sites = @subscriber.sites.order(:latitude) if @subscriber
  end

  def site_params
    params.require(:site).permit(:name, :latitude, :longitude)
  end
end
