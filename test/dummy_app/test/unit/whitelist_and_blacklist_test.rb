require File.expand_path('../../test_helper', __FILE__)

class ArturoWhitelistAndBlacklistTest < ActiveSupport::TestCase

  def feature
    @feature ||= create(:feature)
  end

  def setup
    Arturo::Feature.whitelists.clear
    Arturo::Feature.blacklists.clear
  end

  def test_whitelisting_overrides_percent_calculation
    feature.deployment_percentage = 0
    Arturo::Feature.whitelist(feature.symbol) { |thing| true }
    assert feature.enabled_for?(:a_thing)
  end

  def test_blacklisting_overrides_percent_calculation
    feature.deployment_percentage = 100
    Arturo::Feature.blacklist(feature.symbol) { |thing| true }
    assert !feature.enabled_for?(:a_thing)
  end

  def test_blacklisting_overrides_whitelisting
    Arturo::Feature.whitelist(feature.symbol) { |thing| true }
    Arturo::Feature.blacklist(feature.symbol) { |thing| true }
    assert !feature.enabled_for?(:a_thing)
  end

  def test_lists_can_be_defined_before_feature_is_created
    Arturo::Feature.whitelist(:does_not_exist) { |thing| thing == 'whitelisted' }
    Arturo::Feature.blacklist(:does_not_exist) { |thing| thing == 'blacklisted' }
    @feature = create(:feature, :symbol => :does_not_exist)
    assert  feature.enabled_for?('whitelisted')
    assert !feature.enabled_for?('blacklisted')
  end

  def test_global_whitelisting
    feature.deployment_percentage = 0
    other_feature = create(:feature, :deployment_percentage => 0)
    Arturo::Feature.whitelist { |feature, recipient| feature == other_feature }
    refute feature.enabled_for?(:a_thing)
    assert other_feature.enabled_for?(:a_thing)
  end

  def test_global_blacklisting
    feature.deployment_percentage = 100
    other_feature = create(:feature, :deployment_percentage => 100)
    Arturo::Feature.blacklist { |feature, recipient| feature == other_feature }
    assert feature.enabled_for?(:a_thing)
    refute other_feature.enabled_for?(:a_thing)
  end
end
