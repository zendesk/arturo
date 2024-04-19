# frozen_string_literal: true
require 'arturo/middleware'
require 'rails/engine'

module Arturo
  class Engine < ::Rails::Engine
    root = File.expand_path("../../..", __FILE__)
    config.autoload_paths = ["#{root}/app/helpers", "#{root}/app/controllers"]
    config.eager_load_paths = []
  end
end
