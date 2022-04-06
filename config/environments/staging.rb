# Just use the production settings
require File.expand_path("../production.rb", __FILE__)

Rails.application.configure do
  config.action_mailer.default_url_options = {host: "dev.agweather.cals.wisc.edu"}
end
