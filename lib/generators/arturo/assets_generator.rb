require 'rails/generators'

module Arturo
  class AssetsGenerator < Rails::Generators::Base
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_assets
      copy_file 'arturo.css',                 'public/stylesheets/arturo.css', :force => true
      copy_file 'arturo_customizations.css',  'public/stylesheets/arturo_customizations.css', :skip => true
      copy_file 'arturo.js',                  'public/javascripts/arturo.js'
      copy_file 'colon.png',                  'public/images/colon.png'
    end

  end
end

