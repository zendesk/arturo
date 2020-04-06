# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
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

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6.0') && ActionPack.version < Gem::Version.new('5.0.0')
  module ActionControllerTestResponseThreadingPatch
    def recycle!
      # hack to avoid MonitorMixin double-initialize error:
      @mon_mutex_owner_object_id = nil
      @mon_mutex = nil
      initialize
    end
  end

  ActionController::TestResponse.prepend ActionControllerTestResponseThreadingPatch
else
  ActiveSupport::Deprecation.warn <<~WARN
    ActionController::TestResponse monkey patch at #{__FILE__}:#{__LINE__} will no longer be needed when Rails 4.x support is dropped.
  WARN
end
