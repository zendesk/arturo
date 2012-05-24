module Arturo

  # Adds whitelist and blacklist support to individual features by name.
  # Blacklists override whitelists. (In the world of Apache, Features
  # are "(deny,allow)".)
  # @example
  #   # allow admins:
  #   Arturo::Feature.whitelist(:some_feature) do |user|
  #     user.is_admin?
  #   end
  #
  #   # disallow for small accounts:
  #   Arturo::Feature.blacklist(:another_feature) do |user|
  #     user.account.small?
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
        @whitelists ||= {}
      end

      def blacklists
        @blacklists ||= {}
      end

      def whitelist(feature_symbol, &block)
        whitelists[feature_symbol.to_sym] = block
      end

      def blacklist(feature_symbol, &block)
        blacklists[feature_symbol.to_sym] = block
      end
    end

    def _enabled_for?(feature_recipient)
      return false if blacklisted?(feature_recipient)
      return true if  whitelisted?(feature_recipient)
      super
    end
    private :_enabled_for?


    protected

    def whitelisted?(feature_recipient)
      x_listed?(self.class.whitelists, feature_recipient)
    end

    def blacklisted?(feature_recipient)
      x_listed?(self.class.blacklists, feature_recipient)
    end

    def x_listed?(list_map, feature_recipient)
      list = list_map[self.symbol.to_sym]
      list.present? && list.call(feature_recipient)
    end

  end

end
