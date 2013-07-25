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

    def self.extended(base)
      class << base
        alias_method_chain :to_feature, :caching
        attr_accessor :cache_ttl, :feature_cache
      end
      base.send(:after_save) do |f|
        if f.class.caches_features?
          f.class.feature_cache.write(f.symbol.to_sym, f, :expires_in => base.cache_ttl)
        end
      end
      base.cache_ttl = 0
      base.feature_cache = Arturo::FeatureCaching::Cache.new
      base.caching_strategy = AllStrategy
    end

    def caches_features?
      self.cache_ttl.to_i > 0
    end

    # Wraps Arturo::Feature.to_feature with in-memory caching.
    def to_feature_with_caching(feature_or_symbol)
      if !caches_features?
        to_feature_without_caching(feature_or_symbol)
      elsif feature_or_symbol.kind_of?(Arturo::Feature)
        feature_or_symbol
      else
        symbol = feature_or_symbol.to_sym
        caching_strategy.call(feature_cache, symbol) || Arturo::NoSuchFeature.new(symbol)
      end
    end

    def warm_cache!
      warn "Deprecated, no longer necessary!"
    end

    class AllStrategy
      def self.call(cache, symbol)
        features = cache.read("arturo.all")
        if features && (cache.read("arturo.current") || features.values.map(&:updated_at).max == Arturo::Feature.maximum(:updated_at))
          features
        else
          features = Hash[Arturo::Feature.all.map { |f| [f.symbol.to_sym, f] }]
          cache.write("arturo.current", true, :expires_in => cache_ttl)
          cache.write("arturo.all", features)
        end
        features[symbol]
      end
    end

    class OneStrategy
      def self.call(cache, symbol)
        cache.read("arturo.#{symbol}")
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
