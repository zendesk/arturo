# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'bundler/setup'
require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module DummyApp
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.precompile += %w( arturo.js )
    config.action_controller.action_on_unpermitted_parameters = :raise if Rails.version > "4.0.0"
    config.active_record.raise_in_transactional_callbacks = true if Rails.version > "4.2.0" && Rails::VERSION::MAJOR < 5
    config.active_support.deprecation = :raise
    config.secret_key_base = 'dsdsdshjdshdshdshdshjdhjshjsdhjdsjhdshjds'
    config.i18n.enforce_available_locales = true
  end
end
