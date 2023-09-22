# frozen_string_literal: true
require 'arturo/no_such_feature'

module Arturo

  # To be extended by Arturo::Feature if you want to enable
  # in-memory caching.
  # NB: Arturo's feature caching only works when using
  # Arturo::Feature.to_feature or when using the helper methods
  # in Arturo and Arturo::FeatureAvailability.
  # NB: if you have multiple application servers, you almost certainly
  # want to clear this cache after each request:
  #
  #   class ApplicationController < ActionController::Base
  #     after_filter { Arturo::Feature.clear_feature_cache }
  #   end
  #
  # Alternatively, you could redefine Arturo::Feature.feature_cache
  # to use a shared cache like Memcached.
  module FeatureCaching

    module PrependMethods
      # Wraps Arturo::Feature.to_feature with in-memory caching.
      def to_feature(feature_or_symbol)
        if !caches_features?
          super
        elsif feature_or_symbol.kind_of?(Arturo::Feature)
          feature_or_symbol
        else
          symbol = feature_or_symbol.to_sym
          feature_caching_strategy.fetch(feature_cache, symbol) { super(symbol) }
        end
      end
    end

    def self.extended(base)
      class << base
        prepend PrependMethods
        attr_accessor :cache_ttl, :feature_cache, :feature_caching_strategy
        attr_writer :extend_cache_on_failure
      end
      base.send(:after_save) do |f|
        f.class.feature_caching_strategy.expire(f.class.feature_cache, f.symbol.to_sym) if f.class.caches_features?
      end
      base.cache_ttl = 0
      base.extend_cache_on_failure = false
      base.feature_cache = Arturo::FeatureCaching::Cache.new
      base.feature_caching_strategy = AllStrategy
    end

    def extend_cache_on_failure?
      !!@extend_cache_on_failure
    end

    def caches_features?
      self.cache_ttl.to_i > 0
    end

    def warm_cache!
      to_feature(:fake_feature_to_force_cache_warming)
    end

    class AllStrategy
      class << self
        ##
        # @param cache [Arturo::Cache] cache backend
        # @param symbol [Symbol] arturo identifier
        # @return [Arturo::Feature, Arturo::NoSuchFeature] 
        #
        def fetch(cache, symbol, &block)
          existing_features = cache.read("arturo.all")

          features = if cache_is_current?(cache, existing_features)
            existing_features
          else
            arturos_from_origin(fallback: existing_features).tap do |updated_features|
              update_and_extend_cache!(cache, updated_features)
            end
          end

          features[symbol] || Arturo::NoSuchFeature.new(symbol)
        end

        def expire(cache, symbol)
          cache.delete("arturo.all")
        end

        def register_cache_update_listener(&block)
          cache_update_listeners << block
        end

        private

        def cache_update_listeners
          @cache_update_listeners ||= []
        end

        ##
        # @param fallback [Hash] features to use on database failure
        # @return [Hash] updated features from origin or fallback
        # @raise [ActiveRecord::ActiveRecordError] on database failure
        #   without cache extension option
        #
        def arturos_from_origin(fallback:)
          Hash[Arturo::Feature.all.map { |f| [f.symbol.to_sym, f] }]
        rescue ActiveRecord::ActiveRecordError
          raise unless Arturo::Feature.extend_cache_on_failure?

          if fallback.blank?
            log_empty_cache
            raise
          else
            log_stale_cache
            fallback
          end
        end

        ##
        # @return [Boolean] whether the current cache has to be updated from origin
        # @raise [ActiveRecord::ActiveRecordError] on database failure
        #   without cache extension option
        #
        def cache_is_current?(cache, features)
          return unless features
          return true if cache.read("arturo.current")

          begin
            return false if origin_changed?(features)  
          rescue ActiveRecord::ActiveRecordError
            raise unless Arturo::Feature.extend_cache_on_failure?

            if features.blank?
              log_empty_cache
              raise
            else
              log_stale_cache
              update_and_extend_cache!(cache, features)
            end

            return true
          end
          mark_as_current!(cache)
        end

        def formatted_log(namespace, msg)
          "[Arturo][#{namespace}] #{msg}"
        end

        def log_empty_cache
          Arturo.logger.error(formatted_log('extend_cache_on_failure', 'Fallback cache is empty'))
        end

        def log_stale_cache
          Arturo.logger.warn(formatted_log('extend_cache_on_failure', 'Falling back to stale cache'))
        end

        ##
        # @return [True]
        #
        def mark_as_current!(cache)
          cache.write("arturo.current", true, expires_in: Arturo::Feature.cache_ttl)
        end

        ##
        # The Arturo origin might return a big payload, so checking for the latest
        # update is a cheaper operation.
        #
        # @return [Boolean] if origin has been updated since the last cache update.
        #
        def origin_changed?(features)
          features.values.map(&:updated_at).compact.max != Arturo::Feature.maximum(:updated_at)
        end

        def update_and_extend_cache!(cache, features)
          mark_as_current!(cache)
          cache.write("arturo.all", features, expires_in: Arturo::Feature.cache_ttl * 10)
          cache_update_listeners.each(&:call)
        end
      end
    end

    class OneStrategy
      def self.fetch(cache, symbol, &block)
        if feature = cache.read("arturo.#{symbol}")
          feature
        else
          cache.write("arturo.#{symbol}", yield || Arturo::NoSuchFeature.new(symbol), expires_in: Arturo::Feature.cache_ttl)
        end
      end

      def self.expire(cache, symbol)
        cache.delete("arturo.#{symbol}")
      end
    end

    # Quack like a Rails cache.
    class Cache
      def initialize
        @data = {} # of the form {key => [value, expires_at or nil]}
      end

      def read(name, options = nil)
        value, expires_at = *@data[name]
        if value && (expires_at.blank? || expires_at > Time.now)
          value
        else
          nil
        end
      end

      def delete(name)
        @data.delete(name)
      end

      def write(name, value, options = nil)
        expires_at = if options && options.respond_to?(:[]) && options[:expires_in]
          Time.now + options.delete(:expires_in)
        else
          nil
        end
        value.freeze.tap do |val|
          @data[name] = [value, expires_at]
        end
      end

      def clear
        @data.clear
      end
    end

  end

end
