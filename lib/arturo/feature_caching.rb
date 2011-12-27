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
      class <<base
        alias_method_chain :to_feature, :caching
        attr_accessor :cache_ttl, :feature_cache, :cache_warming_enabled
      end
      base.cache_warming_enabled = false
      base.cache_ttl = 0
      base.feature_cache = Arturo::FeatureCaching::Cache.new
    end

    def caches_features?
      self.cache_ttl.to_i > 0
    end

    def cache_warming_enabled?
      caches_features? && (true == cache_warming_enabled)
    end

    # Wraps Arturo::Feature.to_feature with in-memory caching.
    def to_feature_with_caching(feature_or_symbol)
      if !self.caches_features?
        return to_feature_without_caching(feature_or_symbol)
      elsif (feature_or_symbol.kind_of?(Arturo::Feature))
        feature_cache.write(feature_or_symbol.symbol, feature_or_symbol, :expires_in => cache_ttl)
        feature_or_symbol
      elsif (cached_feature = feature_cache.read(feature_or_symbol.to_sym))
        cached_feature
      elsif (f = to_feature_without_caching(feature_or_symbol))
        if cache_warming_enabled?
          warm_feature_cache
        else
          feature_cache.write(f.symbol, f, :expires_in => cache_ttl)
        end
        f
      end
    end

    protected

    def warm_feature_cache
      all(:order => "id DESC").each do |f|
        feature_cache.write(f.symbol, f, :expires_in => cache_ttl)
      end
    end

    # Quack like a Rails cache.
    class Cache
      def initialize
        @data = {} # of the form {key => [value, expires_at or nil]}
      end
      def read(name, options = nil)
        name = name.to_s
        value, expires_at = *@data[name]
        if value && (expires_at.blank? || expires_at > Time.now)
          value
        else
          nil
        end
      end
      def write(name, value, options = nil)
        name = name.to_s
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
