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
  end
end
