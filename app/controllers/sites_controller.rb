class SitesController < ApplicationController
  before_action :get_subscriber_from_session, :get_sites

  def index
  end

  def show
    @lat = params[:lat].to_f.round(1)
    @long = params[:long].to_f.round(1)
    @valid = validate_lat(@lat) && validate_long(@long)
    if @valid && params[:etc].present?
      redirect_to(action: :show, lat: @lat, long: @long)
    end

    @start_date_opts = {
      "7 days" => 7.days.ago.to_date,
      "2 weeks" => 14.days.ago.to_date,
      "1 month" => 1.month.ago.to_date,
      "This year" => Date.current.beginning_of_year
    }
    @start_date = 7.days.ago.to_date
    @end_date = Date.yesterday
    @units = (params[:units] == "metric") ? "metric" : "imperial"

    if @valid && @subscriber
      @subscriber_site = @sites.where(latitude: @lat, longitude: @long).first
    end

    @passed_params = {
      controller: :weather,
      action: :site_data,
      lat: @lat,
      long: @long,
      start_date: @start_date,
      end_date: @end_date,
      units: @units
    }
  rescue
    redirect_to action: :index
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

  private

  def get_sites
    @sites = @subscriber.sites.order(:latitude) if @subscriber
  end

  def site_params
    params.require(:site).permit(:name, :latitude, :longitude)
  end
end
