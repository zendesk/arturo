ENV["RAILS_ENV"] = "test"
require 'bundler/setup'
require "active_support/core_ext/load_error"
MissingSourceFile::REGEXPS << [/^cannot load such file -- (.+)$/i, 1]

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/rg'
require 'test_help'

require 'mocha'
require 'factory_girl'
require 'timecop'

require File.expand_path('../prepare_database', __FILE__)
require 'arturo'
require 'arturo/feature'
require 'arturo/feature_factories'
require 'arturo/test_support'

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
