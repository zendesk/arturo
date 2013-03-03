if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 1
  Rails.application.routes.draw do
    resources :features, :controller => 'arturo/features'
    put 'features', :to => 'arturo/features#update_all', :as => 'features'
  end
else
  Arturo::Engine.routes.draw do
    resources :features, :controller => 'arturo/features'
    put 'features', :to => 'arturo/features#update_all', :as => 'features'
  end
end
