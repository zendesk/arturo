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

    # Looks up a feature by name. Also accepts a Feature as input.
    # @param [String, Arturo::Feature] feature_or_name a Feature or a name of a Feature
    # @return [Arturo::Feature, nil] the Feature if found, else nil
    def self.to_feature(feature_or_name)
      return feature_or_name if feature_or_name.kind_of?(self)
      self.where(:name => feature_or_name.to_s).first
    end

    # Create a new Feature
    def initialize(attributes = {})
      super(DEFAULT_ATTRIBUTES.merge(attributes || {}))
    end

    # @param [Object] thing_that_has_features a User, Account,
    #                 or other model with an #id method
    # @return [true,false] whether or not this feature is enabled
    #                      for thing_that_has_features
    def enabled_for?(thing_that_has_features)
      return false if thing_that_has_features.nil?
      threshold = self.deployment_percentage || 0
      return false if threshold == 0
      return true if threshold == 100
      (((thing_that_has_features.id + 17) * 13) % 100) < threshold
    end

    def to_s
      "Feature #{name}"
    end

    def to_param
      persisted? ? "#{id}-#{name.parameterize}" : nil
    end

    def inspect
      "<Arturo::Feature #{name}, deployed to #{deployment_percentage}%>"
    end
  end
end
