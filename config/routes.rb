# Helper for easy routing and dasherizing. Default verb is :get.
def route(action, verb = :get, *other_verbs)
  match action.dasherize, to: action, via: [verb] + other_verbs
end

Rails.application.routes.draw do

  get "site/:lat,:long(,:etc)", to: "sites#show", constraints: {
    lat: /[-+]?\d+\.?\d*/,
    long: /[-+]?\d+\.?\d*/
  }
  get "sites", to: "sites#index"
  get "site", to: redirect("/sites")
  get "site/(*path)", to: redirect("/sites")

  # TODO: change this to home controller?
  resources :navigation, path: "", only: :index do
    collection do
      route "about"
      route "king_hall"
    end
  end
  get "/", to: "navigation#index" # default action
  get "/navigation/(*path)", to: redirect("/", status: 404) unless Rails.env.development?

  resources :awon, only: :index do
    collection do
      route "awon_check_boxes"
      route "select_data"
      route "station_info"
      route "download_data", :get, :post
      # get "awon_seven_day"
      # get "graphs"
      # get "graphs_soiltemp"
      # get "blog"
    end
  end
  get "/awon", to: "awon#index" # default action
  get "/awon/(*path)", to: redirect("/awon", status: 404) unless Rails.env.development?

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
      route "hyd"
      route "hyd_grid"
      route "doycal"
      route "doycal_grid"
    end
  end
  get "/weather", to: "weather#index" # default action
  get "/weather/(*path)", to: redirect("/weather", status: 404) unless Rails.env.development?

  resources :sun_water, path: "/sun-water", only: :index do
    collection do

      route "map_image", :get, :post
    end
  end
  get "/sun-water", to: "sun_water#index" # default action
  get "/sun-water/(*path)", to: redirect("/sun-water", status: 404) unless Rails.env.development?

  resources :thermal_models, path: "/thermal-models", only: :index do
    collection do
      route "dd_map", :get, :post
      route "degree_days"
      route "alfalfa_weevil"
      route "corn_dev"
      route "corn_stalk_borer"
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
  get "/thermal-models", to: "thermal_models#index" # default action
  get "/thermal-models/(*path)", to: redirect("/thermal-models", status: 404) unless Rails.env.development?


  resources :subscribers, only: [:index, :new, :create, :update, :destroy] do
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
    end
  end
  match "/subscribers", to: "subscribers#index", via: [:get, :post]
  get "/subscribers/(*path)", to: redirect("/subscribers", status: 404) unless Rails.env.development?

  resources :subscriptions

  # Custom URLs
  direct :vdifn do "/vdifn" end
  direct :wisp do "https://wisp.cals.wisc.edu" end
  direct :vegpath do "https://vegpath.plantpath.wisc.edu" end
  direct :vegento do "https://vegento.russell.wisc.edu" end

  root to: "navigation#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # catch old underscored URLs
  get "/thermal_models/(*path)", to: redirect("/thermal-models")
  get "/sun_water/(*path)", to: redirect("/sun-water")

  get "*unmatched", to: redirect("/", status: 404) unless Rails.env.development?
  post "*unmatched", to: "application#bad_request" unless Rails.env.development?
  post "/", to: "application#bad_request" unless Rails.env.development?
end
