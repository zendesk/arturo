# frozen_string_literal: true

require_relative 'arturo/null_logger'
require_relative 'arturo/special_handling'
require_relative 'arturo/feature_methods'
require_relative 'arturo/feature_availability'
require_relative 'arturo/feature_management'
require_relative 'arturo/feature_caching'
require_relative 'arturo/engine' if defined?(Rails)

module Arturo
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
