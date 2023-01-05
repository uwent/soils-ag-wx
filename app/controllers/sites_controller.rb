class SitesController < ApplicationController
  before_action :get_subscriber_from_session

  def index
    if params[:lat] && params[:long]
      @lat = params[:lat].to_f.round(1)
      @long = params[:long].to_f.round(1)
      @valid = validate_lat(@lat) && validate_long(@long)
      if @valid && params[:etc].present?
        redirect_to(action: :index, lat: @lat, long: @long)
      end
    end

    @title = @lat && @long && @valid ? "Point data for #{@lat}, #{@long}" : "Point data"

    if @subscriber
      @sites = @subscriber.sites
    end
  end

  private

end
