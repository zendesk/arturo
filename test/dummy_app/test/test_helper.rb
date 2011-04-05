ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'bundler'
Bundler.setup

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/unit'
require 'mocha'
require 'factory_girl'
require 'timecop'

require File.expand_path('../prepare_database', __FILE__)
require 'arturo'
require 'arturo/feature'
require 'arturo/feature_factories'

class ActiveSupport::TestCase
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

MiniTest::Unit.autorun
