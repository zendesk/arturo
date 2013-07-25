require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

describe "caching" do
  Arturo::Feature.extend(Arturo::FeatureCaching)

  class StupidCache
    def initialize
      @data = {}
    end

    def read(key)
      @data[key]
    end

    def write(key, value, options={})
      @data[key] = value
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

  it "hits db on first load" do
    Arturo::Feature.expects(:where).once.returns([@feature.reload])
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "hits cache on subsequent loads within ttl" do
    Arturo::Feature.expects(:where).once.returns([@feature.reload])
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "does not hit cache for subsequent loads outside of ttl" do
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.expects(:where).once.returns([@feature.reload])
    Timecop.travel(Time.now + Arturo::Feature.cache_ttl - 5.seconds)
    Arturo::Feature.to_feature(@feature.symbol)
    Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "caches missing features" do
    Arturo::Feature.expects(:where).once.returns([])
    assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
    assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
    assert_kind_of Arturo::NoSuchFeature, Arturo::Feature.to_feature(:ramen)
  end

  it "works with other cache backends" do
    Arturo::Feature.feature_cache = StupidCache.new
    Arturo::Feature.expects(:where).once.returns([@feature.reload])
    Arturo::Feature.to_feature(@feature.symbol.to_sym)
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.to_feature(@feature.symbol.to_sym)
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "can clear the cache" do
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.feature_cache.clear
    Arturo::Feature.expects(:where).once.returns([@feature.reload])
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "can turn off caching" do
    Arturo::Feature.cache_ttl = 0
    Arturo::Feature.expects(:where).twice.returns([@feature.reload])
    Arturo::Feature.to_feature(@feature.symbol)
    Arturo::Feature.to_feature(@feature.symbol)
  end

  it "can warm the cache" do
    second_feature = create(:feature)
    Arturo::Feature.warm_cache!

    Arturo::Feature.expects(:where).never
    assert_equal @feature, Arturo::Feature.to_feature(@feature.symbol)
    assert_equal second_feature, Arturo::Feature.to_feature(second_feature.symbol)
  end

end
