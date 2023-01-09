class SitesController < ApplicationController
  before_action :get_subscriber_from_session, :get_sites

  def index
    @title = "Site data"
    @welcome_image = "awon.png"
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

    @title = @lat && @long && @valid ? "Data dashboard for location #{@lat}, #{@long}" : "Site data"
    @welcome_image = "awon.png"
  end

  def update
    return reject if @subscriber.nil? || !@subscriber.admin?
    site = Site.find(params[:id])
    return reject unless @subscriber.sites.include? site
    site.update!(site_params.compact)
    render json: { message: "success" }
  rescue => e
    render json: { message: e }, status: 422
  end

  private

  def get_sites
    @sites = @subscriber.sites.order(:latitude) if @subscriber
  end

  def site_params
    params.require(:site).permit(:name, :latitude, :longitude)
  end

end
