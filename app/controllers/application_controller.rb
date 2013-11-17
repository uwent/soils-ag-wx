class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_tab_selected
  
  private
  def set_tab_selected
    selects = {
      :awon => :weather,
      :cranberry => :sun_water,
      :drought => :drought,
      :navigation => :about,
      :products => :subscriptions,
      :subscribers => :subscriptions,
      :subscriptions => :subscriptions,
      :sun_water => :sun_water,
      :thermal_models => :thermal_models,
      :weather => :weather
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
end