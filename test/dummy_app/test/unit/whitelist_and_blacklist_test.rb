require File.expand_path('../../test_helper', __FILE__)

class ArturoWhitelistAndBlacklistTest < ActiveSupport::TestCase

  def feature
    @feature ||= Factory(:feature)
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
    Arturo::Feature.whitelists[:does_not_exist] = lambda { |thing| thing == 'whitelisted' }
    Arturo::Feature.blacklists[:does_not_exist] = lambda { |thing| thing == 'blacklisted' }
    @feature = Factory(:feature, :symbol => :does_not_exist)
    assert  feature.enabled_for?('whitelisted')
    assert !feature.enabled_for?('blacklisted')
  end

end
