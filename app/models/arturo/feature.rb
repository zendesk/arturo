require 'active_record'

# a stub
# possible TODO: remove and and refactor into an acts_as_feature mixin
module Arturo
  class Feature < ::ActiveRecord::Base

    DEFAULT_ATTRIBUTES = { :deployment_percentage => 0 }

    validates_presence_of :name, :deployment_percentage
    validates_uniqueness_of :name, :allow_blank => true
    validates_numericality_of :deployment_percentage,
                                            :only_integer => true,
                                            :allow_blank => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than_or_equal_to => 100

    # Create a new Feature
    def initialize(attributes = {})
      super(DEFAULT_ATTRIBUTES.merge(attributes || {}))
    end

    # @param [Object] thing_that_has_features a User, Account,
    #                 or other model with an #id method
    # @return [true,false] whether or not this feature is enabled
    #                      for thing_that_has_features
    def enabled_for?(thing_that_has_features)
      threshold = self.deployment_percentage || 0
      return false if threshold == 0
      return true if threshold == 100
      (((thing_that_has_features.id + 17) * 13) % 100) < threshold
    end
  end
end
