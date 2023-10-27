# frozen_string_literal: true
require 'rails/generators'

module Arturo
  class FeatureModelGenerator < Rails::Generators::Base
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_feature_model_file
      copy_file "feature.rb", "app/models/arturo/feature.rb"
    end
  end
end
