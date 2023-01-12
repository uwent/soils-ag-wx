# Helper for easy routing and dasherizing. Default verb is :get.
def route(action, verb = :get, *other_verbs)
  match action.dasherize, to: action, via: [verb] + other_verbs
end

Rails.application.routes.draw do
  
  root to: "home#index"

  # Navigation controller
  get "about", to: "home#about"
  get "king-hall", to: "home#king_hall"
  get "home", to: redirect("")

  # Weather controller
  resources :weather, only: :index do
    collection do
      route "awon"
      route "weather", :get, :post
      route "precip", :get, :post
      route "et", :get, :post
      route "insol", :get, :post
      route "map_image", :get, :post
      route "weather_data"
      route "precip_data"
      route "et_data"
      route "insol_data"
      route "site_data"
      route "hyd"
      route "hyd_grid"
      route "doycal"
      route "doycal_grid"
    end
  end
  get "weather", to: "weather#index" # default action
  get "weather/(*path)", to: redirect("weather")
  get "sun-water/(*path)", to: redirect("weather", status: 301)
  get "sun_water/(*path)", to: redirect("weather", status: 301)

  # Sites controller
  resources :sites, only: :none do
    put :update, on: :member
  end
  get "sites/:lat,:long", to: "sites#show", constraints: {
    lat: /[-+]?\d+\.?\d*/,
    long: /[-+]?\d+\.?\d*/
  }
  get "sites", to: "sites#index"
  get "sites/(*path)", to: redirect("sites")

  # AWON controller
  resources :awon, only: :index do
    collection do
      route "awon_check_boxes"
      route "station_info"
      route "download_data", :post
    end
  end
  get "awon", to: "awon#index"
  get "awon/(*path)", to: redirect("/awon")

  # Thermal models controller
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
  get "thermal-models", to: "thermal_models#index" # default action
  get "thermal-models/(*path)", to: redirect("/thermal-models")
  get "thermal_models/(*path)", to: redirect("/thermal-models", status: 301)

  # Subscribers controller
  resources :subscribers do
    collection do
      route "admin"
      route "manage", :get, :post
      route "logout"
      route "export"
    end
    member do
      route "confirm"
      route "confirm_notice"
      route "unsubscribe"
      route "send_email"
      route "validate", :post
      route "resend_confirmation", :post
      route "add_site", :post
      route "remove_site", :post
      route "enable_site", :post
      route "disable_site", :post
      route "enable_subscription", :post
      route "disable_subscription", :post
      route "enable_emails", :post
      route "disable_emails", :post
      route "edit", :post
    end
  end
  match "subscribers", to: "subscribers#index", via: [:get, :post]
  get "/subscribers/(*path)", to: redirect("/subscribers")

  # Custom URLs
  direct :vdifn do "/vdifn" end
  direct :wisp do "https://wisp.cals.wisc.edu" end
  direct :vegpath do "https://vegpath.plantpath.wisc.edu" end
  direct :vegento do "https://vegento.russell.wisc.edu" end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "*unmatched", to: redirect("/")
  post "*unmatched", to: "application#bad_request" unless Rails.env.development?
  post "/", to: "application#bad_request" unless Rails.env.development?
end
