WCP::Application.routes.draw do 

  resources :blueprints do
    post :add_step
    get :resort_steps
    post :delete_step
  end

  # User / Login Routes
  match "login" => "login#login", :as => :login
  match "login/missing_password"
  post "login/logout", :as => :logout
  
  # Account Routes
  get "account" => "account#index", :as => :account

  match "account/update", :as => :account_update

  # Company Routes
  get 'company' => 'company#index', :as => :company_config
  post 'company/update' => 'company#update', :as => :company_config_update

  resources :companies

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'dashboard(/:action)' => 'dashboard', :as => :dashboard

  root :to => "dashboard#index" 

  resources :machine_blueprints, :except => [ :show ]

  resources :clouds do
    post :reset
  end
  resources :deployments do
    collection do
      post :cleanup
    end
  end

  resources :machines, :except => [ :new, :create ]  do
    collection do 
      post :cleanup
    end
  end

  resources :machines
end
