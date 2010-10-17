module Arturo

  require 'arturo/railtie' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'arturo/configuration'
  require 'arturo/feature'

end
