# Just use the production settings
require File.expand_path("../production.rb", __FILE__)

# Overwrite production defaults
Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: ENV["AG_WEATHER_HOST"] || "dev.agweather.cals.wisc.edu",
    protocol: "https"
  }
end
