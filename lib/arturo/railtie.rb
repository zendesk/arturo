module Arturo
  class Railtie < ::Rails::Railtie
    # Rails-3.0.1 requires config.app_generators instead of 3.0.0's config.generators
    generators = config.respond_to?(:app_generators) ? config.app_generators : config.generators
  end
end
