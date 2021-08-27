Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

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

  resources :navigation, only: [:index] do
    collection do
      get 'about'
    end
  end
  match '/navigation', to: 'navigation#index', via: [:get, :post]

  resources :sun_water, only: [:index] do
    collection do
      get 'insol_us'
      get 'insol_model'
      get 'et_wimn'
      get 'et_fl'
      get 'et_model'
      get 'spreadsheet_download'
      get 'spreadsheet_doc'
      get 'grid_ets'
      get 'grid_insols'
      get 'get_grid'
      post 'get_grid'
    end
  end
  match '/sun_water', to: 'sun_water#index', via: [:get, :post]

  resources :thermal_models, only: [:index] do
    collection do
      get 'degree_days'
      get 'corn'
      get 'corn_dev'
      get 'ecb'
      get 'alfalfa'
      get 'corn_stalk_borer'
      get 'potato'
      get 'tree'
      get 'scm'
      get 'wiDDs'
      get 'wiDDs_csv'
      get 'westernbeancutworm'
      get 'scm_doc'
      get 'remaining_dds'
      get 'remaining_dd_map_for'
      get 'frost_map'
      get 'oak_wilt'
      get 'get_dds'
      post 'get_dds'
      get 'get_dds_many_locations'
      post 'get_dds_many_locations'
      get 'get_oak_wilt_dd'
      post 'get_oak_wilt_dd'
      post 'download_csv'
    end
  end
  match '/thermal_models', to: 'thermal_models#index', via: [:get, :post]

  resources :weather, only: [:index] do
    collection do
      get 'hyd'
      get 'awon'
      get 'grid_temps'
      get 'webcam'
      get 'doycal'
      get 'doycal_grid'
      get 'get_grid'
      post 'get_grid'
      get 'webcam_archive'
      post 'webcam_archive'
      get 'kinghall'
    end
  end
  match '/weather', to: 'weather#index', via: [:get, :post]

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

  post 'wi_mn_dets/get_grid'
  get 't411s/last'

  root to: 'navigation#index'

  # if Rails.env.development?
  #   mount LetterOpenerWeb::Engine, at: '/letter_opener'
  # end

  get '*path', to: redirect('/')

end
