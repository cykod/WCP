WCP::Application.routes.draw do |map|


  resources :blueprints do
    member do
      post :add_step
      get :resort_steps
    end

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

  resources :clouds
  resources :deployments
  get 'machines(.:format)' => 'machines#index'
  get 'machines/:id(.:format)' => 'machines#show'
  get 'machines/:id/edit' => 'machines#edit'
  put 'machines/:id(.:format)' => 'machines#update'
  delete 'machines/:id(.:format)' => 'machines#destroy'


  resources :machines
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
