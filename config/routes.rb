Rails.application.routes.draw do

  resources :awon, only: [:index] do
    collection do
      get 'awon_check_boxes'
      get 'awon_seven_day'
      get 'select_data'
      get 'station_info'
      get 'graphs'
      get 'graphs_soiltemp'
      get 'blog'
      get 'download_data'
      post 'download_data'
    end
  end
  match '/awon', to: 'awon#index', via: [:get, :post]
  get '/awon/*path', to: redirect('/awon') unless Rails.env.development?

  resources :heartbeat, only: [:index] do
    collection do
      get 'awon'
      get 'asos'
      get 'hyd'
      get 'dd'
      get 'et'
      get 'insol'
      get 'ping'
      get 'webapps'
      get 'asos_grids'
    end
  end
  match '/heartbeat', to: 'heartbeat#index', via: [:get, :post]
  get '/heartbeat/*path', to: redirect('/heartbeat') unless Rails.env.development?
  

  resources :navigation, only: [:index] do
    collection do
      get 'about'
    end
  end
  match '/navigation', to: 'navigation#index', via: [:get, :post]
  get '/navigation/*path', to: redirect('/navigation') unless Rails.env.development?

  resources :sun_water, only: [:index] do
    collection do
      get 'insol_map'
      post 'insol_map'
      get 'et_map'
      post 'et_map'
      get 'grid_ets'
      get 'grid_insols'
      get 'get_grid'
      post 'get_grid'
      get 'insol_us', to: redirect('sun_water/insol_map')
      get 'et_wimn', to: redirect('sun_water/et_map')
    end
  end
  match '/sun_water', to: 'sun_water#index', via: [:get, :post]
  get '/sun_water/*path', to: redirect('/sun_water') unless Rails.env.development?

  resources :thermal_models, only: [:index] do
    collection do
      get 'alfalfa_weevil'
      get 'corn_dev'
      get 'corn_stalk_borer'
      get 'corn'
      get 'degree_days'
      get 'ecb'
      get 'frost_map'
      get 'get_dds_many_locations'
      post 'get_dds_many_locations'
      get 'get_dds'
      post 'get_dds'
      get 'get_oak_wilt_dd'
      post 'get_oak_wilt_dd'
      get 'gypsy'
      get 'gypsyinfo'
      get 'many_degree_days_for_date'
      get 'oak_wilt'
      get 'potato'
      get 'scm'
      get 'tree'
      get 'western_bean_cutworm'
      post 'download_csv'
    end
  end
  match '/thermal_models', to: 'thermal_models#index', via: [:get, :post]
  get '/thermal_models/*path', to: redirect('/thermal_models') unless Rails.env.development?

  resources :weather, only: [:index] do
    collection do
      get 'awon'
      get 'doycal'
      get 'doycal_grid'
      get 'get_grid'
      post 'get_grid'
      get 'grid_temps'
      post 'grid_temps'
      get 'hyd'
      get 'hyd_grid'
      get 'webcam'
      get 'webcam_archive'
      post 'webcam_archive'
      get 'kinghall'
    end
  end
  match '/weather', to: 'weather#index', via: [:get, :post]
  get '/weather/*path', to: redirect('/weather') unless Rails.env.development?

  resources :subscribers do
    collection do
      get 'admin'
      get 'manage'
      post 'manage'
      get 'logout'
      get 'export_emails'
    end
    member do
      get 'confirm'
      get 'confirm_notice'
      get 'unsubscribe'
      post 'validate'
      post 'resend_confirmation'
      post 'add_subscription'
      post 'remove_subscription'
    end
  end
  match '/subscribers', to: 'subscribers#index', via: [:get, :post]
  get '/subscribers/*path', to: redirect('/subscribers') unless Rails.env.development?

  # post 'wi_mn_dets/get_grid'
  # get 't411s/last'

  direct :vdifn do
    Rails.env.staging? ? "https://dev.agweather.cals.wisc.edu/vdifn" : "https://agweather.cals.wisc.edu/vdifn"
  end

  direct :wisp do
    Rails.env.staging? ? "https://dev.wisp.cals.wisc.edu" : "https://wisp.cals.wisc.edu"
  end

  root to: 'navigation#index'

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  get '*path', to: redirect('/') unless Rails.env.development?

end
