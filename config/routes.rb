SoilsAgWx::Application.routes.draw do
  get "thermal_models/index"
  get "thermal_models/degree_days"
  get "thermal_models/corn"
  get "thermal_models/corn_dev"
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
  match "/thermal_models", to: "thermal_models#index", via: [:get, :post]
  get "sun_water/index"
  get "sun_water/insol_east_us"
  get "sun_water/insol_west_us"
  get "sun_water/insol_model"
  get "sun_water/et_wimn"
  get "sun_water/et_fl"
  get "sun_water/et_model"
  get "sun_water/spreadsheet_download"
  get "sun_water/spreadsheet_doc"
  match "/sun_water", to: "sun_water#index", via: [:get, :post]
  get "weather/index"
  get "weather/hyd"
  get "weather/awon"
  get "weather/grid_temps"
  get "weather/webcam"
  get "navigation/index"
  get "navigation/about"
  match "/navigation", to: "navigation#index", via: [:get, :post]
  resources :t401s

  resources :t406s

  resources :t403s

  resources :t412s

  resources :awon_stations

  resources :wi_mn_dets

  resources :products

  resources :subscriptions

  resources :subscribers

  resources :blogs

  resources :t411s
  
  root to: 'navigation#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end