Xss::Application.routes.draw do
  get "home/index"
  root :to => 'home#index'

  # Base tests
  match "base_test/sanitizers_form/:method(/:option)", :controller => 'base_test', :action => 'sanitizers_form', :via => 'get', :as => 'base_test_sanitizers_form'
  match "base_test/sanitizers_perform/:method(/:option)", :controller => 'base_test', :action => 'sanitizers_perform', :via => 'post', :as => 'base_test_sanitizers_perform'

end
