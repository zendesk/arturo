require File.expand_path('../../test_helper', __FILE__)

class NoSuchFeatureTest < ActiveSupport::TestCase

  def setup
    reset_translations!
  end

  def feature
    @feature ||= Arturo::NoSuchFeature.new(:an_unknown_feature)
  end

  def test_is_not_enabled
    refute feature.enabled_for?(nil)
    refute feature.enabled_for?(stub('User', :to_s => 'Saorse', :id => 12))
  end

  def test_requires_a_symbol
    assert_raises(ArgumentError) do
      Arturo::NoSuchFeature.new(nil)
    end
  end

  def test_to_s
    assert feature.to_s.include?(feature.name)
  end

end
