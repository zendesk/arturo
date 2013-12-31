module Arturo
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include Arturo::FeatureAvailability
      helper  Arturo::FeatureAvailability
      include Arturo::ControllerFilters
      helper  Arturo::FeatureManagement
    end

    root = File.expand_path("../../..", __FILE__)
    config.autoload_paths = ["#{root}/app/helpers", "#{root}/app/controllers"]
    config.eager_load_paths = []
  end
end
