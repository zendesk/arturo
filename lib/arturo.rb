# frozen_string_literal: true
module Arturo
  require 'arturo/null_logger'
  require 'arturo/special_handling'
  require 'arturo/feature_availability'
  require 'arturo/feature_management'
  require 'arturo/feature_caching'
  require 'arturo/engine' if defined?(Rails)

  class << self
    # Quick check for whether a feature is enabled for a recipient.
    # @param [String, Symbol] feature_name
    # @param [#id] recipient
    # @return [true,false] whether the feature exists and is enabled for the recipient
    def feature_enabled_for?(feature_name, recipient)
      f = self::Feature.to_feature(feature_name)
      f && f.enabled_for?(recipient)
    end

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger || NullLogger.new
    end
  end
end
