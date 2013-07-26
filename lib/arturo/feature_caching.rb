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

    # A marker in the cache to record the fact that the feature with the
    # given symbol doesn't exist.
    NO_SUCH_FEATURE = :NO_SUCH_FEATURE

    def self.extended(base)
      class << base
        alias_method_chain :to_feature, :caching
        attr_accessor :cache_ttl, :feature_cache, :feature_caching_strategy
      end
      base.send(:after_save) do |f|
        f.class.feature_caching_strategy.expire(f.class.feature_cache, f.symbol.to_sym) if f.class.caches_features?
      end
      base.cache_ttl = 0
      base.feature_cache = Arturo::FeatureCaching::Cache.new
      base.feature_caching_strategy = AllStrategy
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
        feature = feature_caching_strategy.fetch(feature_cache, symbol) { to_feature_without_caching(symbol) }
        feature unless feature == NO_SUCH_FEATURE
      end
    end

    def warm_cache!
      warn "Deprecated, no longer necessary!"
    end

    class AllStrategy
      def self.fetch(cache, symbol, &block)
        features = cache.read("arturo.all")
        if features && (cache.read("arturo.current") || features.values.map(&:updated_at).max == Arturo::Feature.maximum(:updated_at))
          features
        else
          features = Hash[Arturo::Feature.all.map { |f| [f.symbol.to_sym, f] }]
          cache.write("arturo.current", true, :expires_in => Arturo::Feature.cache_ttl)
          cache.write("arturo.all", features, :expires_in => Arturo::Feature.cache_ttl * 2)
        end
        features[symbol] || NO_SUCH_FEATURE
      end

      def self.expire(cache, symbol)
        cache.delete("arturo.all")
      end
    end

    class OneStrategy
      def self.fetch(cache, symbol, &block)
        if feature = cache.read("arturo.#{symbol}")
          feature
        else
          cache.write("arturo.#{symbol}", yield || NO_SUCH_FEATURE, :expires_in => Arturo::Feature.cache_ttl)
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
