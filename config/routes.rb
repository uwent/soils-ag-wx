# Helper for easy routing and dasherizing. Default verb is :get.
def route(action, verb = :get, *other_verbs)
  match action.dasherize, to: action, via: [verb] + other_verbs
end

Rails.application.routes.draw do

  # TODO: change this to home controller?
  resources :navigation, path: "", only: :index do
    collection do
      route "about"
      route "king_hall"
    end
  end
  get "/", to: "navigation#index" # default action
  get "/navigation/(*path)", to: redirect("/") unless Rails.env.development?

  resources :awon, only: :index do
    collection do
      route "awon_check_boxes"
      route "select_data"
      route "station_info"
      route "download_data"
      route "download_data", :get, :post
      # get "awon_seven_day"
      # get "graphs"
      # get "graphs_soiltemp"
      # get "blog"
    end
  end
  get "/awon", to: "awon#index" # default action
  get "/awon/(*path)", to: redirect("/awon") unless Rails.env.development?

  # resources :heartbeat, only: :index do
  #   collection do
  #     get "awon"
  #     get "asos"
  #     get "hyd"
  #     get "dd"
  #     get "et"
  #     get "insol"
  #     get "ping"
  #     get "webapps"
  #     get "asos_grids"
  #   end
  # end
  # match "/heartbeat", to: "heartbeat#index", via: [:get, :post]
  # get "/heartbeat/*path", to: redirect("/heartbeat") unless Rails.env.development?

  resources :weather, only: :index do
    collection do
      route "awon"
      route "doycal"
      route "doycal_grid"
      route "weather_map", :get, :post
      route "weather_data"
      route "hyd"
      route "hyd_grid"
      route "precip_map", :get, :post
      route "precip_data"
      route "map_image", :post
    end
  end
  get "/weather", to: "weather#index" # default action
  get "/weather/(*path)", to: redirect("/weather") unless Rails.env.development?

  resources :sun_water, path: "/sun-water", only: :index do
    collection do
      route "insol_map", :get, :post
      route "insol_data"
      route "et_map", :get, :post
      route "et_data"
      route "map_image", :get, :post
    end
  end
  get "/sun-water", to: "sun_water#index" # default action
  get "/sun-water/(*path)", to: redirect("/sun-water") unless Rails.env.development?
  get "/sun_water/(*path)", to: redirect("/sun-water") unless Rails.env.development? # catch old underscores

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
  get "/thermal-models/(*path)", to: redirect("/thermal-models") unless Rails.env.development?
  get "/thermal_models/(*path)", to: redirect("/thermal-models") unless Rails.env.development? # catch old underscores

  resources :subscribers, only: [:index, :new, :create, :update, :destroy] do
    collection do
      route "admin"
      route "manage"
      route "logout"
      route "export"
      route "manage", :post
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
    end
  end
  match "/subscribers", to: "subscribers#index", via: [:get, :post]
  get "/subscribers/(*path)", to: redirect("/subscribers") unless Rails.env.development?

  resources :subscriptions

  # Custom URLs
  direct :vdifn do "/vdifn" end
  direct :wisp do "https://wisp.cals.wisc.edu" end
  direct :vegpath do "https://vegpath.plantpath.wisc.edu" end
  direct :vegento do "https://vegento.russell.wisc.edu" end

  root to: "navigation#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "*unmatched", to: redirect("/") unless Rails.env.development?
  post "*unmatched", to: "application#bad_request" unless Rails.env.development?
  post "/", to: "application#bad_request" unless Rails.env.development?
end
