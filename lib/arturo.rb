module Arturo

  require 'arturo/special_handling'
  require 'arturo/feature_availability'
  require 'arturo/feature_management'
  require 'arturo/controller_filters'
  require 'arturo/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

end
