# frozen_string_literal: true
module Arturo

  # A mixin that provides #feature_enabled? and #if_feature_enabled
  # methods; to be mixed in by Controllers and Helpers. The including
  # class must return some "thing that has features" (e.g. a User, Person,
  # or Account) when Arturo.feature_recipient is bound to an instance
  # and called.
  #
  # @see Arturo.feature_recipient
  module FeatureAvailability

    def feature_enabled?(symbol_or_feature)
      feature = ::Arturo::Feature.to_feature(symbol_or_feature)
      return false if feature.blank?
      feature.enabled_for?(feature_recipient)
    end

    def if_feature_enabled(symbol_or_feature, &block)
      if feature_enabled?(symbol_or_feature)
        block.call
      else
        nil
      end
    end

    # By default, returns current_user.
    # 
    # If you would like to change this implementation, it is recommended
    # you do so in config/initializers/arturo_initializer.rb
    # @return [Object] the recipient of features.
    def feature_recipient
      current_user
    end

  end

end
