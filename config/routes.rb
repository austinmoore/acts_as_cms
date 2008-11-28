ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.root :pages

  map.static ':id', :controller => 'pages', :action => 'show'
end
