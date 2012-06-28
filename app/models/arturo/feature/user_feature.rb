module Arturo
  class UserFeature < Feature
    def base_class
      UserFeature
    end

    # @param [Object] feature_recipient a User, Account,
    #                 or other model with an #id method
    # @return [true,false] whether or not this feature is enabled
    #                      for feature_recipient
    # @see Arturo::SpecialHandling#whitelisted?
    # @see Arturo::SpecialHandling#blacklisted?
    def enabled_for?(feature_recipient)
      return false if feature_recipient.nil?
      return false if blacklisted?(feature_recipient)
      return true if  whitelisted?(feature_recipient)
      passes_threshold?(feature_recipient)
    end

    def inspect
      "<Arturo::UserFeature #{name}, deployed to #{deployment_percentage}%>"
    end

    protected

    def passes_threshold?(feature_recipient)
      threshold = self.deployment_percentage || 0
      return false if threshold == 0
      return true if threshold == 100
      (((feature_recipient.id + (self.id || 1) + 17) * 13) % 100) < threshold
    end
  end
end
