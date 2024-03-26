# Load production defaults
require File.expand_path("../production.rb", __FILE__)

# Staging settings
Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: ENV["AG_WEATHER_HOST"] || "dev.agweather.cals.wisc.edu",
    protocol: "https"
  }
  config.log_level = :debug
end
