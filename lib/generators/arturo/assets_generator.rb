require 'rails/generators'

module Arturo
  class AssetsGenerator < Rails::Generators::Base
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_assets
      copy_file 'arturo.css',                 'public/stylesheets/arturo.css', :force => true
      copy_file 'arturo_customizations.css',  'public/stylesheets/arturo_customizations.css', :skip => true
      copy_file 'semicolon.png',              'public/images/semicolon.png'
    end

  end
end

