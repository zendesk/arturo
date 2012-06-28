module Arturo
  class GlobalFeature < Feature
    def base_class
      GlobalFeature
    end

    # @return [true,false] whether or not this feature is enabled
    def enabled?
      deployment_percentage == 100
    end

    # @param [Object] feature_recipient a User, Account,
    #                 or other model with an #id method
    # @return [true,false] whether or not this feature is enabled
    # really just an alias for #enabled?
    def enabled_for?(feature_recipient)
      enabled?
    end

    def enable!
      update_attribute :deployment_percentage, 100
    end

    def disable!
      update_attribute :deployment_percentage, 0
    end

    def inspect
      "<Arturo::GlobalFeature #{name}, state: #{enabled? ? "enabled" : "disabled"}>"
    end

  end
end
