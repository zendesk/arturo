require 'rails_generator'

class ArturoGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'initializer.rb',              'config/initializers/arturo_initializer.rb'
      m.file 'arturo.css',                  'public/stylesheets/arturo.css', :collision => :force
      m.file 'arturo_customizations.css',   'public/stylesheets/arturo_customizations.css', :collision => :skip
      m.file 'arturo.js',                   'public/javascripts/arturo.js'
      m.file 'semicolon.png',               'public/images/semicolon.png'
      m.migration_template 'migration.rb',  'db/migrate', :migration_file_name => 'create_features'
      add_feature_routes(m)
    end
  end

  protected

  def source_root
    File.expand_path('../templates', __FILE__)
  end

  def banner
    %{Usage: #{$0} #{spec.name}\nCopies an initializer; copies CSS, JS, and PNG assets; generates a migration; adds routes/}
  end

  def add_feature_routes(manifest)
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    logger.route "map.resources features"
    unless options[:pretend]
      manifest.gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}#{feature_routes}\n"
      end
    end
  end

  def feature_routes
    "\n  map.resources :features,  :controller => 'arturo/features'" +
    "\n  map.features  'features', :controller => 'arturo/features', :action => 'update_all', :conditions => { :method => :put }"
  end
end
