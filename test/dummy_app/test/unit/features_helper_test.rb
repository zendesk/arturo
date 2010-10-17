require File.expand_path('../../test_helper', __FILE__)
require 'arturo/features_helper'

class ArturoFeaturesHelperTest < ActiveSupport::TestCase

  def setup
    @feature = Factory(:feature)
    @helper = Object.new.tap do |h|
      h.extend Arturo::FeaturesHelper
    end
    @block = lambda { 'Content that requires a feature' }
  end

  def test_if_feature_enabled_with_nonexistent_feature
    @block.expects(:call).never
    assert_nil @helper.if_feature_enabled('nonexistent', &@block)
  end

  def test_if_feature_enabled_with_disabled_feature
    @feature.stubs(:enabled_for?).returns(false)
    @block.expects(:call).never
    assert_nil @helper.if_feature_enabled(@feature.name, &@block)
  end

  def test_if_feature_enabled_with_enabled_feature
    @feature.stubs(:enabled_for?).returns(true)
    @block.expects(:call).once.returns('result')
    assert_equal 'result', @helper.if_feature_enabled(@feature.name, &@block)
  end

end
