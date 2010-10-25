module Arturo
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include Arturo::FeatureAvailability
      helper  Arturo::FeatureAvailability
      include Arturo::ControllerFilters
    end
  end
end
