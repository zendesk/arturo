require 'rails/generators'

module Arturo
  class AssetsGenerator < Rails::Generators::Base

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_assets
      copy_file 'arturo_customizations.css',  'public/stylesheets/arturo_customizations.css', :skip => true

      unless defined?(Sprockets)
        copy_file 'app/assets/stylesheets/arturo.css', 'public/stylesheets/arturo.css', :force => true
        copy_file 'app/assets/javascripts/arturo.js',  'public/javascripts/arturo.js'
        copy_file 'app/assets/images/colon.png',       'public/images/colon.png'
      end
    end

  end
end

