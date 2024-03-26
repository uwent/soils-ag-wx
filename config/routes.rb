# Helper for easy routing and dasherizing. Default verb is :get.
def route(action, verb = :get, *other_verbs)
  match action.dasherize => "#{@controller}##{action}", via: [verb] + other_verbs
end

Rails.application.routes.draw do
  root to: "home#index"

  # Navigation controller
  get "about" => "home#about"
  get "king-hall" => "home#king_hall"
  get "home" => redirect("")

  # Weather controller
  @controller = :weather
  resources :weather, only: :index do
    collection do
      route "awon"
      match "data" => "weather#weather", via: [:get, :post]
      route "precip", :get, :post
      route "et", :get, :post
      route "insol", :get, :post
      route "map_image", :get, :post
      route "weather_data"
      route "precip_data"
      route "et_data"
      route "insol_data"
      route "hyd"
      route "hyd_grid"
      route "doycal"
      route "doycal_grid"
    end
  end
  get "weather" => "weather#index" # default action
  get "weather/(*path)" => redirect("weather") if Rails.env.production?

  # Sites controller
  @controller = :sites
  resources :sites, only: :none do
    collection do
      route "site_data_weather"
      route "site_data_dd"
    end
    member do
      put :update
    end
  end
  get "sites/:lat,:long" => "sites#show", constraints: {
    lat: /[-+]?\d+\.?\d*/,
    long: /[-+]?\d+\.?\d*/
  }
  get "sites" => "sites#index"
  get "sites/(*path)" => redirect("sites")

  # AWON controller
  @controller = :awon
  resources :awon, only: :index do
    collection do
      route "awon_check_boxes"
      route "station_info"
      route "download_data", :post
    end
  end
  get "awon", to: "awon#index"
  get "awon/(*path)", to: redirect("/awon") if Rails.env.production?

  # Thermal models controller
  @controller = :thermal_models
  resources :thermal_models, path: "thermal-models", only: :index do
    collection do
      route "alfalfa_weevil"
      route "corn_dev"
      route "corn_stalk_borer"
      route "dd_map", :get, :post
      route "degree_days"
      route "ecb"
      route "frost_map"
      route "get_dds", :get, :post
      route "spongy_moth"
      route "oak_wilt"
      route "oak_wilt_dd", :get, :post
      route "potato"
      route "potato_data"
      route "scm"
      route "western_bean_cutworm"
      route "map_image", :post
      route "download_csv", :post
    end
  end
  get "thermal-models" => "thermal_models#index" # default action
  get "thermal-models/(*path)" => redirect("/thermal-models") if Rails.env.production?

  # Subscribers controller
  @controller = :subscribers
  resources :subscribers, only: %i[index new create update destroy] do
    collection do
      route "admin"
      route "manage", :get, :post
      route "account", :get, :post
      route "logout"
      route "export"
    end
    member do
      route "confirm"
      route "confirm_account"
      route "validate", :get, :post
      route "unsubscribe"
      route "send_email"
      route "reset_token", :post
      route "resend_confirmation", :post
      route "add_site", :post
      route "remove_site", :post
      route "enable_site", :post
      route "disable_site", :post
      route "enable_subscription", :post
      route "disable_subscription", :post
      route "enable_emails", :post
      route "disable_emails", :post
    end
  end
  match "subscribers", to: "subscribers#index", via: [:get, :post]
  get "/subscribers/(*path)", to: redirect("/subscribers")

  # Custom URLs
  direct(:api) { "/api" }
  direct(:vdifn) { "/vdifn" }
  direct(:wisp) { "https://wisp.cals.wisc.edu" }
  direct(:vegpath) { "https://vegpath.plantpath.wisc.edu" }
  direct(:vegento) { "https://vegento.russell.wisc.edu" }
  direct(:ento) { "https://entomology.wisc.edu" }

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "/ag_weather" => redirect("/api/")
  get "*unmatched" => redirect("/") if Rails.env.production?
  post "*unmatched" => "application#bad_request" if Rails.env.production?
  post "/" => "application#bad_request" if Rails.env.production?
end
