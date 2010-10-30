ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'bundler'
Bundler.setup
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require 'mocha'
require 'factory_girl'

require File.expand_path('../prepare_database', __FILE__)
require 'arturo'
require 'arturo/feature'
require 'arturo/feature_factories'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  def reset_translations!
    I18n.reload!
  end

  def define_translation(key, value)
    hash = key.to_s.split('.').reverse.inject(value) do |value, key_part|
      { key_part.to_sym => value }
    end
    I18n.backend.store_translations I18n.locale, hash
  end
end
