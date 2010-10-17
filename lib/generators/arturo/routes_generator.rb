require 'rails/generators'

module Arturo
  class RoutesGenerator < Rails::Generators::Base

    def add_routes
      route "resources :features, :controller => 'arturo/features'"
    end

  end
end
