# frozen_string_literal: true
module Arturo

  # Adds whitelist and blacklist support to individual features by name
  # or for all features. Blacklists override whitelists. (In the world of
  # Apache, Features are "(deny,allow)".)
  # @example
  #   # allow admins for some_feature:
  #   Arturo::Feature.whitelist(:some_feature) do |user|
  #     user.is_admin?
  #   end
  #
  #   # disallow for small accounts for another_feature:
  #   Arturo::Feature.blacklist(:another_feature) do |user|
  #     user.account.small?
  #   end
  #
  #   # allow large accounts access to large features:
  #   Arturo::Feature.whitelist do |feature, user|
  #     feature.symbol.to_s =~ /^large/ && user.account.large?
  #   end
  #
  # Blacklists and whitelists can be defined before the feature exists
  # and are not persisted, so they are best defined in initializers.
  # This is particularly important if your application runs in several
  # different processes or on several servers.
  module SpecialHandling

    def self.included(base)
      base.extend Arturo::SpecialHandling::ClassMethods
    end

    module ClassMethods

      def whitelists
        @whitelists ||= []
      end

      def blacklists
        @blacklists ||= []
      end

      def whitelist(feature_symbol = nil, &block)
        whitelists << two_arg_block(feature_symbol, block)
      end

      def blacklist(feature_symbol = nil, &block)
        blacklists << two_arg_block(feature_symbol, block)
      end

      private

      def two_arg_block(symbol, block)
        return block if symbol.nil?
        lambda do |feature, recipient|
          feature.symbol.to_s == symbol.to_s && block.call(recipient)
        end
      end

    end

    protected

    def whitelisted?(feature_recipient)
      x_listed?(self.class.whitelists, feature_recipient)
    end

    def blacklisted?(feature_recipient)
      x_listed?(self.class.blacklists, feature_recipient)
    end

    def x_listed?(lists, feature_recipient)
      lists.any? { |block| block.call(self, feature_recipient) }
    end

  end

end
