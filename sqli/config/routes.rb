Sqli::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  match "create_test/class_new(/:method)(/:amount)", :controller => 'create_test', :action => 'class_new', :via => 'get', :as => 'create_test_class_new'
  match "create_test/class_create(/:method)(/:amount)", :controller => 'create_test', :action => 'class_create', :via => 'post', :as => 'create_test_class_create'

  match "update_test/object_single_edit/:id(/:method)", :controller => 'update_test', :action => 'object_single_edit', :via => 'get', :as => 'update_test_object_single_edit'
  match "update_test/object_single_update/:id(/:method)", :controller => 'update_test', :action => 'object_single_update', :via => 'put', :as => 'update_test_object_single_update'
  match "update_test/object_multi_edit/:id(/:method)", :controller => 'update_test', :action => 'object_multi_edit', :via => 'get', :as => 'update_test_object_multi_edit'
  match "update_test/object_multi_update/:id(/:method)", :controller => 'update_test', :action => 'object_multi_update', :via => 'put', :as => 'update_test_object_multi_update'
  match "update_test/class_update_edit/(/:method)", :controller => 'update_test', :action => 'class_update_edit', :via => 'get', :as => 'update_test_class_update_edit'
  match "update_test/class_update_update/(/:method)", :controller => 'update_test', :action => 'class_update_update', :via => 'put', :as => 'update_test_class_update_update'
  match "update_test/class_update_all_edit/(/:method)", :controller => 'update_test', :action => 'class_update_all_edit', :via => 'get', :as => 'update_test_class_update_all_edit'
  match "update_test/class_update_all_update/(/:method)", :controller => 'update_test', :action => 'class_update_all_update', :via => 'put', :as => 'update_test_class_update_all_update'

  resources :all_types_objects

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
