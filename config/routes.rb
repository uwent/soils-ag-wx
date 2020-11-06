Rails.application.routes.draw do

  get "heartbeat/index"
  get "heartbeat/awon"
  get "heartbeat/asos"
  get "heartbeat/hyd"
  get "heartbeat/dd"
  get "heartbeat/et"
  get "heartbeat/insol"
  get "heartbeat/ping"
  get "heartbeat/webapps"
  get "heartbeat/asos_grids"
  match "/heartbeat", to: "heartbeat#index", via: [:get, :post]
  get "awon/awon_check_boxes"
  get "awon/select_data"
  get "awon/station_info"
  get "awon/graphs"
  get "awon/graphs_soiltemp"
  get "awon/blog"
  get "awon/awon_seven_day"
  get "awon/download_data"
  match "/awon", to: "awon#index", via: [:get, :post]
  post "awon/download_data"
  get "thermal_models/index"
  get "thermal_models/degree_days"
  get "thermal_models/corn"
  get "thermal_models/corn_dev"
  get "thermal_models/cranberry"
  get "thermal_models/ecb"
  get "thermal_models/alfalfa"
  get "thermal_models/corn_stalk_borer"
  get "thermal_models/potato"
  get "thermal_models/tree"
  get "thermal_models/gypsy"
  get "thermal_models/gypsyinfo"
  get "thermal_models/scm"
  get "thermal_models/wiDDs"
  get "thermal_models/wiDDs_csv"
  get "thermal_models/westernbeancutworm"
  get "thermal_models/scm_doc"
  get "thermal_models/remaining_dds"
  get "thermal_models/remaining_dd_map_for"
  get "thermal_models/frost_map"
  get "thermal_models/oak_wilt"
  get "thermal_models/many_degree_days_for_date"
  post "thermal_models/get_dds_many_locations"
  get "thermal_models/get_dds_many_locations"
  match "/thermal_models", to: "thermal_models#index", via: [:get, :post]
  get "sun_water/index"
  get "sun_water/insol_us"
  get "sun_water/insol_model"
  get "sun_water/et_wimn"
  get "sun_water/et_fl"
  get "sun_water/et_model"
  get "sun_water/spreadsheet_download"
  get "sun_water/spreadsheet_doc"
  get "sun_water/grid_ets"
  match "/sun_water/get_grid", to: "sun_water#get_grid", via: [:get, :post]
  match "/sun_water", to: "sun_water#index", via: [:get, :post]
  get "weather/index"
  get "weather/hyd"
  get "weather/awon"
  get "weather/grid_temps"
  get "weather/webcam"
  get "weather/doycal"
  get "weather/doycal_grid"
  get "weather/hyd"
  post "weather/get_grid"
  post "weather/webcam_archive"
  get "weather/webcam_archive"
  get "weather/kinghall"
  post "wi_mn_dets/get_grid"
  post "thermal_models/get_dds"
  get "navigation/index"
  get "navigation/about"
  get "t411s/last"


  resources :subscribers, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      post :manage
      get :manage
      get :logout
      get :admin
      get :export_emails
    end
    member do
      post :validate
      get :confirm
      get :confirm_notice
      post :resend_confirmation
      post :add_subscription
      post :remove_subscription
      get :unsubscribe
    end
  end

  resources :hyds, only: [:index, :show]

  match "/navigation", to: "navigation#index", via: [:get, :post]
  root to: 'navigation#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end
