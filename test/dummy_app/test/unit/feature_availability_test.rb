require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

class ArturoFeatureAvailabilityTest < ActiveSupport::TestCase

  def setup
    @feature = Factory(:feature)
    @block = lambda { 'Content that requires a feature' }
    @current_user = Object.new
    @helper = Object.new.tap do |h|
      h.extend Arturo::FeatureAvailability
      h.stubs(:current_user).returns(@current_user)
    end
  end

  def test_if_feature_enabled_with_nonexistent_feature
    @block.expects(:call).never
    assert_nil @helper.if_feature_enabled(:nonexistent, &@block)
  end

  def test_if_feature_enabled_uses_feature_recipient
    @feature.expects(:enabled_for?).with(@current_user)
    @helper.if_feature_enabled(@feature, &@block)
  end

  def test_if_feature_enabled_with_disabled_feature
    @feature.stubs(:enabled_for?).returns(false)
    @block.expects(:call).never
    assert_nil @helper.if_feature_enabled(@feature, &@block)
  end

  def test_if_feature_enabled_with_enabled_feature
    @feature.stubs(:enabled_for?).returns(true)
    assert_equal 'Content that requires a feature', @helper.if_feature_enabled(@feature, &@block)
  end

end
