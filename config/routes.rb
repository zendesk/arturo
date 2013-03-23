if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0
  Rails.application.routes.draw do
    scope "/arturo" do
      resources :features, :controller => "arturo/features"
      put 'features', :to => 'arturo/features#update_all', :as => 'features'
    end
  end
else
  Arturo::Engine.routes.draw do
    resources :features, :controller => 'arturo/features'
    put 'features', :to => 'arturo/features#update_all', :as => 'features'
  end
end
