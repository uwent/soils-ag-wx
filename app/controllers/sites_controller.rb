class SitesController < ApplicationController
  before_action :get_subscriber_from_session, :get_sites

  def index
    @title = "Point data"
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

    @title = @lat && @long && @valid ? "Point data for #{@lat}, #{@long}" : "Point data"
    @welcome_image = "awon.png"
  end


  private

  def get_sites
    @sites = @subscriber.sites.order(:latitude) if @subscriber
  end

end
