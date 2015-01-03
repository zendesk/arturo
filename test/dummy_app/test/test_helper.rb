ENV["RAILS_ENV"] = "test"
require 'bundler/setup'

require File.expand_path('../../config/environment', __FILE__)

require 'minitest/autorun'
require 'minitest/rg'

require "mocha/mini_test"

require 'rails/test_help'

require 'factory_girl'
require 'timecop'

require File.expand_path('../prepare_database', __FILE__)
require 'arturo'
require 'arturo/feature'
require 'arturo/feature_factories'
require 'arturo/test_support'

class ActiveSupport::TestCase
  include ::FactoryGirl::Syntax::Methods

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

Minitest::Spec.class_eval do
  include ::FactoryGirl::Syntax::Methods
end

Arturo::IntegrationTest = defined?(ActionDispatch::IntegrationTest) ?
  ActionDispatch::IntegrationTest :
  ActionController::IntegrationTest

MiniTest::Unit.autorun
