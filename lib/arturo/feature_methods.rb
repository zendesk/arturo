# frozen_string_literal: true

require 'active_record'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

module Arturo
  module FeatureMethods
    extend ActiveSupport::Concern
    include Arturo::SpecialHandling

    SYMBOL_REGEX = /^[a-zA-z][a-zA-Z0-9_]*$/
    DEFAULT_ATTRIBUTES = { :deployment_percentage => 0 }.with_indifferent_access

    included do
      attr_readonly :symbol

      validates_presence_of :symbol, :deployment_percentage
      validates_uniqueness_of :symbol, :allow_blank => true, :case_sensitive => false
      validates_numericality_of :deployment_percentage,
                                :only_integer => true,
                                :allow_blank => true,
                                :greater_than_or_equal_to => 0,
                                :less_than_or_equal_to => 100
    end

    class_methods do
      # Looks up a feature by symbol. Also accepts a Feature as input.
      # @param [Symbol, Arturo::Feature] feature_or_symbol a Feature or the Symbol of a Feature
      # @return [Arturo::Feature, Arturo::NoSuchFeature] the Feature if found, else Arturo::NoSuchFeature
      def to_feature(feature_or_symbol)
        return feature_or_symbol if feature_or_symbol.kind_of?(self)

        symbol = feature_or_symbol.to_sym.to_s
        self.where(:symbol => symbol).first || Arturo::NoSuchFeature.new(symbol)
      end

      # Looks up a feature by symbol. Also accepts a Feature as input.
      # @param [Symbol, Arturo::Feature] feature_or_symbol a Feature or the Symbol of a Feature
      # @return [Arturo::Feature, nil] the Feature if found, else nil
      def find_feature(feature_or_symbol)
        feature = to_feature(feature_or_symbol)
        feature.is_a?(Arturo::NoSuchFeature) ? nil : feature
      end

      def last_updated_at
        maximum(:updated_at)
      end
    end

    # Create a new Feature
    def initialize(*args, &block)
      args[0] = DEFAULT_ATTRIBUTES.merge(args[0].try(:to_h) || {})
      super(*args, &block)
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
      passes_threshold?(feature_recipient, deployment_percentage || 0)
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

    def inspect
      "<Arturo::Feature #{name}, deployed to #{deployment_percentage}%>"
    end

    # made public so as to allow for thresholds stored outside of the model
    def passes_threshold?(feature_recipient, threshold)
      return true if threshold == 100
      return false if threshold == 0 || !feature_recipient.id
      (((feature_recipient.id + (self.id || 1) + 17) * 13) % 100) < threshold
    end
  end
end
