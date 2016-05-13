# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
require 'bundler/setup'

require_relative 'dummy_app/config/environment'

require 'minitest/autorun'
require 'minitest/rg'

require "mocha/mini_test"

require 'rails/test_help'

require 'factory_girl'
require 'timecop'

require_relative 'prepare_database'
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
