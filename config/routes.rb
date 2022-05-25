Rails.application.routes.draw do
  resources :subscriptions
  resources :awon, only: :index do
    collection do
      get "awon_check_boxes"
      # get "awon_seven_day"
      get "select_data"
      get "station_info"
      # get "graphs"
      # get "graphs_soiltemp"
      # get "blog"
      get "download_data"
      post "download_data"
    end
  end
  match "/awon", to: "awon#index", via: [:get, :post]
  get "/awon/*path", to: redirect("/awon") unless Rails.env.development?

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

  resources :navigation, path: "", only: :index do
    collection do
      get "about"
      get "king_hall"
    end
  end
  match "/navigation", to: "navigation#index", via: :get
  get "/navigation/*path", to: redirect("/navigation") unless Rails.env.development?

  resources :subscribers, only: [:index, :new, :create, :update, :destroy] do
    collection do
      get "admin"
      get "manage"
      get "logout"
      get "export_emails"
      post "manage"
    end
    member do
      get "confirm"
      get "confirm_notice"
      get "unsubscribe"
      get "send_email"
      post "validate"
      post "resend_confirmation"
      post "add_site"
      post "remove_site"
      post "enable_site"
      post "disable_site"
      post "enable_subscription"
      post "disable_subscription"
    end
  end
  match "/subscribers", to: "subscribers#index", via: [:get, :post]
  get "/subscribers/*path", to: redirect("/subscribers") unless Rails.env.development?

  resources :sun_water, only: :index do
    collection do
      get "insol_map"
      post "insol_map"
      get "insol_data"
      get "insol_us", to: redirect("sun_water/insol_map", status: 301)
      get "et_map"
      post "et_map"
      post "map_image"
      get "et_data"
      get "et_wimn", to: redirect("sun_water/et_map", status: 301)
    end
  end
  match "/sun_water", to: "sun_water#index", via: [:get, :post]
  get "/sun_water/*path", to: redirect("/sun_water") unless Rails.env.development?

  # get "t411s/last"

  resources :thermal_models, only: :index do
    collection do
      get "alfalfa_weevil"
      get "corn_dev"
      get "corn_stalk_borer"
      get "dd_map"
      post "dd_map"
      post "map_image"
      get "degree_days"
      get "ecb"
      get "frost_map"
      # get "get_dds_many_locations"
      # post "get_dds_many_locations"
      get "get_dds"
      post "get_dds"
      get "spongy_moth"
      # get "many_degree_days_for_date"
      get "oak_wilt"
      get "oak_wilt_dd"
      post "oak_wilt_dd"
      get "potato"
      get "potato_data"
      get "scm"
      # get "tree"
      get "western_bean_cutworm"
      post "download_csv"
    end
  end
  match "/thermal_models", to: "thermal_models#index", via: [:get, :post]
  get "/thermal_models/*path", to: redirect("/thermal_models") unless Rails.env.development?

  resources :weather, only: :index do
    collection do
      get "awon"
      get "doycal"
      get "doycal_grid"
      get "weather_map"
      post "weather_map"
      get "weather_data"
      get "hyd"
      get "hyd_grid"
      get "precip_map"
      post "precip_map"
      get "precip_data"
      post "map_image"
      # get "webcam"
      # get "webcam_archive"
      # post "webcam_archive"
    end
  end
  match "/weather", to: "weather#index", via: [:get, :post]
  get "/weather/*path", to: redirect("/weather") unless Rails.env.development?

  # post 'wi_mn_dets/get_grid'

  direct :vdifn do
    "/vdifn"
  end

  direct :wisp do
    "https://wisp.cals.wisc.edu"
  end

  direct :vegpath do
    "https://vegpath.plantpath.wisc.edu"
  end

  direct :vegento do
    "https://vegento.russell.wisc.edu"
  end

  root to: "navigation#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "*path", to: redirect("/") unless Rails.env.development?
end
