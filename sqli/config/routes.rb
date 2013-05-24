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
end
