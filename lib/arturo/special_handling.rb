# frozen_string_literal: true
module Arturo

  # Adds grantlist and blocklist support to individual features by name
  # or for all features. Blocklists override grantlists. (In the world of
  # Apache, Features are "(deny,allow)".)
  # @example
  #   # allow admins for some_feature:
  #   Arturo::Feature.grantlist(:some_feature) do |user|
  #     user.is_admin?
  #   end
  #
  #   # disallow for small accounts for another_feature:
  #   Arturo::Feature.blocklist(:another_feature) do |user|
  #     user.account.small?
  #   end
  #
  #   # allow large accounts access to large features:
  #   Arturo::Feature.grantlist do |feature, user|
  #     feature.symbol.to_s =~ /^large/ && user.account.large?
  #   end
  #
  # Blocklists and grantlists can be defined before the feature exists
  # and are not persisted, so they are best defined in initializers.
  # This is particularly important if your application runs in several
  # different processes or on several servers.
  module SpecialHandling

    def self.included(base)
      base.extend Arturo::SpecialHandling::ClassMethods
    end

    module ClassMethods

      def grantlists
        @grantlists ||= []
      end
      alias whitelists grantlists

      def blocklists
        @blocklists ||= []
      end
      alias blacklists blocklists

      def grantlist(feature_symbol = nil, &block)
        grantlists << two_arg_block(feature_symbol, block)
      end
      alias whitelist grantlist

      def blocklist(feature_symbol = nil, &block)
        blocklists << two_arg_block(feature_symbol, block)
      end
      alias blacklist blocklist

      private

      def two_arg_block(symbol, block)
        return block if symbol.nil?
        lambda do |feature, recipient|
          feature.symbol.to_s == symbol.to_s && block.call(recipient)
        end
      end

    end

    protected

    def grantlisted?(feature_recipient)
      x_listed?(self.class.grantlists, feature_recipient)
    end
    alias whitelisted? grantlisted?

    def blocklisted?(feature_recipient)
      x_listed?(self.class.blocklists, feature_recipient)
    end
    alias blacklisted? blocklisted?

    def x_listed?(lists, feature_recipient)
      lists.any? { |block| block.call(self, feature_recipient) }
    end

  end

end
