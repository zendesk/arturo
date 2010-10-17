#config/routes.rb
Rails.application.routes.draw do |map|
  resources :features, :controller => 'arturo/features'
end
