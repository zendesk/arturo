# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
require 'debug/prelude'
require 'debug/config'
require 'dummy_app/config/environment'
require 'rspec/rails'
require 'factory_bot'
require 'timecop'
require 'support/prepare_database'
require 'arturo'
require 'arturo/feature'
require 'arturo/feature_factories'
require 'arturo/test_support'

RSpec.configure do |config|
  config.include ::FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true

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
