if Rails.version < "3.1.0" # support for rails 2 and 3.0
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
