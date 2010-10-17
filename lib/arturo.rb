module Arturo

  require 'arturo/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'arturo/configuration'
  require 'arturo/special_handling'

end
