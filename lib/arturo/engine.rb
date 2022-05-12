# frozen_string_literal: true
require 'arturo/controller_filters'
require 'arturo/middleware'
require 'rails/engine'

module Arturo
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include Arturo::FeatureAvailability
      include Arturo::ControllerFilters
      if respond_to?(:helper)
        helper  Arturo::FeatureAvailability
        helper  Arturo::FeatureManagement
      end
    end

    root = File.expand_path("../../..", __FILE__)
    config.autoload_paths = ["#{root}/app/helpers", "#{root}/app/controllers"]
    config.eager_load_paths = []
  end
end
