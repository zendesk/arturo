require 'active_record'

# a stub
# possible TODO: remove and and refactor into an acts_as_feature mixin
module Arturo
  class Feature < ::ActiveRecord::Base

    include Arturo::SpecialHandling
    self.inheritance_column = 'class_name'

    Arturo::Feature::SYMBOL_REGEX = /^[a-zA-z][a-zA-Z0-9_]*$/
    DEFAULT_ATTRIBUTES = { :deployment_percentage => 0, :class_name => "Arturo::Feature" }.with_indifferent_access

    attr_readonly :symbol

    validates_presence_of :symbol, :deployment_percentage
    validates_uniqueness_of :symbol, :allow_blank => true
    validates_numericality_of :deployment_percentage,
                                            :only_integer => true,
                                            :allow_blank => true,
                                            :greater_than_or_equal_to => 0,
                                            :less_than_or_equal_to => 100

    # Looks up a feature by symbol. Also accepts a Feature as input.
    # @param [Symbol, Arturo::Feature] feature_or_name a Feature or the Symbol of a Feature
    # @return [Arturo::Feature, nil] the Feature if found, else nil
    def self.to_feature(feature_or_symbol)
      return feature_or_symbol if feature_or_symbol.kind_of?(self)
      self.where(:symbol => feature_or_symbol.to_sym).first
    end

    # Create a new Feature
    def initialize(attributes = {}, options = {}, &block)
      super(DEFAULT_ATTRIBUTES.merge(attributes || {}), options, &block)
    end

    def name
      return I18n.translate("arturo.feature.nameless") if symbol.blank?
      I18n.translate("arturo.feature.#{symbol}", :default => symbol.to_s.titleize)
    end

    def to_s
      "Feature #{name}"
    end

    def to_param
      persisted? ? "#{id}-#{symbol.to_s.parameterize}" : nil
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
      "<Arturo::Feature #{name}, deployed to #{deployment_percentage}%>"
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
