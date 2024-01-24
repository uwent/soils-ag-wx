source "https://rubygems.org"

gem "rails", "7.1.2"
gem "railties", "7.1.2"
gem "activesupport", "7.1.2"
gem "pg"
gem "sassc-rails"
gem "coffee-rails"
gem "jquery-rails"
gem "jquery-ui-rails", github: "jquery-ui-rails/jquery-ui-rails"
gem "rails-ujs"
gem "uglifier"
gem "turbolinks"
gem "httparty"
gem "render_async" # for asynchronous loading of page elements
gem "will_paginate"
gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"
gem "whenever"
gem "terser" # for JS compression
gem "mail" # v2.7 => v2.8.0 required a sendmail settings change, see config/production.rb, should be resolved with mail v2.8.1
gem "csv"

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
  gem "standard" # linter
  gem "brakeman" # security analysis https://brakemanscanner.org/
  gem "bundler-audit" # patch-level verification
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
