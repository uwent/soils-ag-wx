source "https://rubygems.org"

gem "rails", "~> 7.0"
gem "railties", "~> 7.0"
gem "activesupport", "~> 7.0"
gem "pg", "~> 1.3"
gem "sassc-rails", "~> 2.1"
gem "coffee-rails", "~> 5.0"
gem "jquery-rails", "~> 4.4"
gem "jquery-ui-rails", "~> 6.0"
gem "rails-ujs", "~> 0.1"
gem "uglifier", "~> 4.2"
gem "turbolinks", "~> 5.2"
# gem "jbuilder", "~> 2.11"
gem "httparty", "~> 0.20"
gem "render_async", "~> 2.1" # for asynchronous loading of page elements
gem "will_paginate", "~> 3.3"
gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"
gem "whenever", "~> 1.0"
# gem "agwx_grids", "0.0.6" # Use agwx_grids for uploading data from text grids to database
# gem "agwx_biophys", "0.0.4" # Use agwx_biophys for degree days and the like
gem "terser", "~> 1.1" # for JS compression
gem "mail", "2.7.1" # v2.8 might be causing error

group :development do
  gem "puma"
  gem "capistrano"
  gem "capistrano-rbenv"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rails-collection"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "listen"
  gem "standard"
end

group :development, :test do
  gem "spring"
  gem "spring-commands-rspec"
  gem "dotenv-rails"
  gem "pry-rails"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "guard-rspec"
  gem "factory_bot_rails"
end

group :test do
  gem "simplecov"
  gem "webmock"
end
