require File.expand_path('../../test_helper', __FILE__)

class ArturoGlobalFeatureTest < ActiveSupport::TestCase
  def setup
    reset_translations!
  end

  def feature
    @feature ||= Factory(:global_feature)
  end

  def test_to_feature_finds_global_feature
    assert_equal feature, ::Arturo::Feature.to_feature(feature)
    assert_equal feature, ::Arturo::Feature.to_feature(feature.symbol)
    assert_equal Arturo::GlobalFeature, feature.class
  end

  def test_global_feature_overrides_enabled_for
    feature.update_attribute(:deployment_percentage, 100)
    recipient = stub('User', :to_s => 'Paula', :id => 12)
    assert ::Arturo.feature_enabled_for?(feature.symbol, recipient), "#{feature} should be enabled for #{recipient}"

    feature.update_attribute(:deployment_percentage, 99)
    assert !::Arturo.feature_enabled_for?(feature.symbol, recipient), "#{feature} should not be enabled for #{recipient}"
  end

  def test_global_feature_enabled_only_for_full_engagement
    feature.update_attribute(:deployment_percentage, 22)
    assert !feature.enabled?

    feature.update_attribute(:deployment_percentage, 100)
    assert feature.enabled?
  end
end
