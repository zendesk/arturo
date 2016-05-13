# frozen_string_literal: true
Arturo::Engine.routes.draw do
  resources :features, :controller => 'arturo/features'
  put 'features', :to => 'arturo/features#update_all', :as => 'features_update_all'
end
