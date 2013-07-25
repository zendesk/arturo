require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

describe "caching" do
  Arturo::Feature.extend(Arturo::FeatureCaching)

  class StupidCache
    def initialize(enabled=true)
      @enabled = enabled
      @data = {}
    end

    def read(key)
      @data[key] if @enabled
    end

    def delete(key)
      @data.delete(key)
    end

    def write(key, value, options={})
      @data[key] = value
    end

    def clear
      @data.clear
    end
  end

  before do
    @feature = create(:feature)
    Arturo::Feature.cache_ttl = 30.minutes
    Arturo::Feature.feature_cache = Arturo::FeatureCaching::Cache.new
  end

  after do
    Arturo::Feature.cache_ttl = 0 # turn off for other tests
    Timecop.return
  end

  # Rails 4 calls all when calling maximum :/
  def lock_down_maximum
    m = Arturo::Feature.maximum(:updated_at)
    Arturo::Feature.stubs(:maximum).returns(m)
  end

  [Arturo::FeatureCaching::OneStrategy, Arturo::FeatureCaching::AllStrategy].each do |strategy|
    describe "with #{strategy}" do
      let(:method) { strategy == Arturo::FeatureCaching::OneStrategy ? :where : :all }

      before do
        Arturo::Feature.feature_caching_strategy = strategy
      end

      it "hits db on first load" do
        Arturo::Feature.expects(method).once.returns([@feature])
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "caches missing features" do
        Arturo::Feature.expects(method).once.returns([])
        assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
        assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
        assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
      end

      it "works with other cache backends" do
        Arturo::Feature.feature_cache = StupidCache.new
        Arturo::Feature.expects(method).once.returns([@feature])
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "works with inconsistent cache backend" do
        Arturo::Feature.feature_cache = StupidCache.new(false)
        Arturo::Feature.expects(method).twice.returns([@feature])
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
      end

      it "can clear the cache" do
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.feature_cache.clear
        Arturo::Feature.expects(method).once.returns([@feature])
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "can turn off caching" do
        Arturo::Feature.cache_ttl = 0
        Arturo::Feature.expects(:where).twice.returns([@feature])
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "does not expire when inside cache ttl" do
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.expects(method).never

        Timecop.travel(Time.now + Arturo::Feature.cache_ttl - 5.seconds)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "expires when outside of cache ttl" do
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.expects(method).once.returns([@feature])

        Timecop.travel(Time.now + Arturo::Feature.cache_ttl * 3)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it "expires cache on enable or disable" do
        refute_equal 100, Arturo::Feature.to_feature(@feature.symbol).deployment_percentage

        Arturo.enable_feature!(@feature.symbol)
        assert_equal 100, Arturo::Feature.to_feature(@feature.symbol).deployment_percentage

        Arturo.disable_feature!(@feature.symbol)
        assert_equal 0, Arturo::Feature.to_feature(@feature.symbol).deployment_percentage
      end
    end
  end

  describe "with AllStrategy" do
    before do
      Arturo::Feature.feature_caching_strategy = Arturo::FeatureCaching::AllStrategy
    end

    it "caches all features in one cache" do
      Arturo::Feature.expects(:all).once.returns([])
      assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
      assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:amen)
      assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:laymen)
    end

    it "does not expire when inside cache ttl" do
      Arturo::Feature.to_feature(@feature.symbol)
      lock_down_maximum
      Arturo::Feature.expects(:all).never

      Timecop.travel(Time.now + Arturo::Feature.cache_ttl - 5.seconds)
      Arturo::Feature.to_feature(@feature.symbol)
    end

    it "does not expire when outside of cache ttl and fresh" do
      Arturo::Feature.to_feature(@feature.symbol)
      lock_down_maximum
      Arturo::Feature.expects(:all).never

      Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
      Arturo::Feature.to_feature(@feature.symbol)
    end

    it "expires when outside of cache ttl and stale" do
      Arturo::Feature.to_feature(@feature.symbol)
      @feature.touch
      lock_down_maximum
      Arturo::Feature.expects(:all).once.returns([@feature])

      Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
      Arturo::Feature.to_feature(@feature.symbol)
    end
  end
end
