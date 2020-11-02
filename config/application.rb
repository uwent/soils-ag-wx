require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module SoilsAgWx
  class Application < Rails::Application

    config.load_defaults 5.0
    config.time_zone = 'Central Time (US & Canada)'
    
  end
end
