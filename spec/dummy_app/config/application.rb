# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'bundler/setup'
require 'rails/all'
require 'arturo/engine'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module DummyApp
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.precompile += %w( arturo.js ) if config.respond_to?(:assets)
    config.action_controller.action_on_unpermitted_parameters = :raise
    config.active_support.deprecation = :raise
    config.secret_key_base = 'dsdsdshjdshdshdshdshjdhjshjsdhjdsjhdshjds'
    config.i18n.enforce_available_locales = true
  end
end
