module Arturo

  require 'arturo/special_handling'
  require 'arturo/feature_availability'
  require 'arturo/feature_management'
  require 'arturo/feature_caching'
  require 'arturo/controller_filters'
  require 'arturo/range_form_support'
  require 'arturo/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 2 && Rails::VERSION::MINOR == 3

  class <<self

    # Quick check for whether a feature is enabled for a recipient.
    # @param [String, Symbol] feature_name
    # @param [#id] recipient
    # @return [true,false] whether the feature exists and is enabled for the recipient
    def feature_enabled_for?(feature_name, recipient)
      f = self::Feature.to_feature(feature_name)
      f && f.enabled_for?(recipient)
    end

    ENABLED_FOR_METHOD_NAME = /^(\w+)_enabled_for\?$/

    def respond_to?(symbol)
      symbol.to_s =~ ENABLED_FOR_METHOD_NAME || super(symbol)
    end

    def method_missing(symbol, *args, &block)
      if (args.length == 1 && match = ENABLED_FOR_METHOD_NAME.match(symbol.to_s))
        feature_enabled_for?(match[1], args[0])
      else
        super(symbol, *args, &block)
      end
    end

  end
end
