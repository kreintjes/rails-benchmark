Sqli::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  # Create tests
  match "create_test/class_new/:method(/:amount)", :controller => 'create_test', :action => 'class_new', :via => 'get', :as => 'create_test_class_new'
  match "create_test/class_create/:method(/:amount)", :controller => 'create_test', :action => 'class_create', :via => 'post', :as => 'create_test_class_create'

  # Read tests
  match "read_test/class_objects_form/:method(/:option)", :controller => 'read_test', :action => 'class_objects_form', :via => 'get', :as => 'read_test_class_objects_form'
  match "read_test/class_objects_perform/:method(/:option)", :controller => 'read_test', :action => 'class_objects_perform', :via => 'post', :as => 'read_test_class_objects_perform'
  match "read_test/class_value_form/:method(/:option)", :controller => 'read_test', :action => 'class_value_form', :via => 'get', :as => 'read_test_class_value_form'
  match "read_test/class_value_perform/:method(/:option)", :controller => 'read_test', :action => 'class_value_perform', :via => 'post', :as => 'read_test_class_value_perform'
  match "read_test/class_by_sql_form/:method(/:option)", :controller => 'read_test', :action => 'class_by_sql_form', :via => 'get', :as => 'read_test_class_by_sql_form'
  match "read_test/class_by_sql_perform/:method(/:option)", :controller => 'read_test', :action => 'class_by_sql_perform', :via => 'post', :as => 'read_test_class_by_sql_perform'

  # Update tests
  match "update_test/object_single_edit/:id/:method", :controller => 'update_test', :action => 'object_single_edit', :via => 'get', :as => 'update_test_object_single_edit'
  match "update_test/object_single_update/:id/:method", :controller => 'update_test', :action => 'object_single_update', :via => 'put', :as => 'update_test_object_single_update'
  match "update_test/object_multi_edit/:id/:method", :controller => 'update_test', :action => 'object_multi_edit', :via => 'get', :as => 'update_test_object_multi_edit'
  match "update_test/object_multi_update/:id/:method", :controller => 'update_test', :action => 'object_multi_update', :via => 'put', :as => 'update_test_object_multi_update'
  match "update_test/class_update_edit/:method", :controller => 'update_test', :action => 'class_update_edit', :via => 'get', :as => 'update_test_class_update_edit'
  match "update_test/class_update_update/:method", :controller => 'update_test', :action => 'class_update_update', :via => 'put', :as => 'update_test_class_update_update'
  match "update_test/class_update_all_edit/:method", :controller => 'update_test', :action => 'class_update_all_edit', :via => 'get', :as => 'update_test_class_update_all_edit'
  match "update_test/class_update_all_update/:method", :controller => 'update_test', :action => 'class_update_all_update', :via => 'put', :as => 'update_test_class_update_all_update'

  # Delete tests
  match "delete_test/class_delete_form/:method", :controller => 'delete_test', :action => 'class_delete_form', :via => 'get', :as => 'delete_test_class_delete_form'
  match "delete_test/class_delete_perform/:method", :controller => 'delete_test', :action => 'class_delete_perform', :via => 'delete', :as => 'delete_test_class_delete_perform'
  match "delete_test/class_destroy_form/:method", :controller => 'delete_test', :action => 'class_destroy_form', :via => 'get', :as => 'delete_test_class_destroy_form'
  match "delete_test/class_destroy_perform/:method", :controller => 'delete_test', :action => 'class_destroy_perform', :via => 'delete', :as => 'delete_test_class_destroy_perform'
  match "delete_test/class_delete_all_form/:method", :controller => 'delete_test', :action => 'class_delete_all_form', :via => 'get', :as => 'delete_test_class_delete_all_form'
  match "delete_test/class_delete_all_perform/:method", :controller => 'delete_test', :action => 'class_delete_all_perform', :via => 'delete', :as => 'delete_test_class_delete_all_perform'
  match "delete_test/class_destroy_all_form/:method", :controller => 'delete_test', :action => 'class_destroy_all_form', :via => 'get', :as => 'delete_test_class_destroy_all_form'
  match "delete_test/class_destroy_all_perform/:method", :controller => 'delete_test', :action => 'class_destroy_all_perform', :via => 'delete', :as => 'delete_test_class_destroy_all_perform'
  match "delete_test/object_remove/:id/:method", :controller => 'delete_test', :action => 'object_remove', :via => 'get', :as => 'delete_test_object_remove'

  resources :all_types_objects
end
