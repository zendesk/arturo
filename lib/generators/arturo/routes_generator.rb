require 'rails/generators'

module Arturo
  class RoutesGenerator < Rails::Generators::Base

    def add_mount
      if Arturo::Engine.respond_to?(:routes)
        route "mount Arturo::Engine => ''"
      else
        puts "This version of Rails doesn't support Engine-specific routing. Nothing to do."
      end
    end

  end
end
