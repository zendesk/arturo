# frozen_string_literal: true
require 'rails/generators'

module Arturo
  class InitializerGenerator < Rails::Generators::Base
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/arturo_initializer.rb"
    end
  end
end
