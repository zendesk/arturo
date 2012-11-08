if Rails::VERSION::MAJOR == 2 or (Rails::VERSION::MAJOR == 3 and Rails::VERSION::MINOR == 0)
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
