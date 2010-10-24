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
      thing = ::Arturo.feature_recipient.bind(self).call
      feature.enabled_for?(thing)
    end

    def if_feature_enabled(symbol_or_feature, &block)
      if feature_enabled?(symbol_or_feature)
        block.call
      else
        nil
      end
    end

  end

end
