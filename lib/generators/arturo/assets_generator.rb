require 'rails/generators'

module Arturo
  class AssetsGenerator < Rails::Generators::Base

    def self.source_root
      Arturo::Engine.root_path
    end

    def copy_assets
      copy_file 'lib/generators/arturo/templates/arturo_customizations.css',  'public/stylesheets/arturo_customizations.css', :skip => true

      unless defined?(Sprockets)
        copy_file 'app/assets/stylesheets/arturo.css', 'public/stylesheets/arturo.css', :force => true
        copy_file 'app/assets/javascripts/arturo.js',  'public/javascripts/arturo.js'
        copy_file 'app/assets/images/colon.png',       'public/images/colon.png'
      end
    end

  end
end

