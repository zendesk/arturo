module Arturo

  require 'arturo/special_handling'
  require 'arturo/feature_availability'
  require 'arturo/feature_management'
  require 'arturo/controller_filters'
  require 'arturo/range_form_support'
  require 'arturo/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 2 && Rails::VERSION::MINOR == 3

  # Quick check for whether a feature is enabled for a recipient.
  # @param [String, Symbol] feature_name
  # @param [#id] recipient
  # @return [true,false] whether the feature exists and is enabled for the recipient
  def self.feature_enabled_for?(feature_name, recipient)
    f = self::Feature.to_feature(feature_name)
    f && f.enabled_for?(recipient)
  end

end
