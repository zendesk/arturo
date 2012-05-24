require File.expand_path('../../test_helper', __FILE__)

class ArturoFeaturesOverrideTest < ActiveSupport::TestCase
  def feature
    @feature ||= Factory(:feature)
  end

  module OtherHandling
    def _enabled_for?(feature_recipient)
      feature_recipient.owns_monkey?
    end
  end

  def test_can_override_enabled_for
    feature.extend(OtherHandling)
    feature_recipient = "User1"
    feature_recipient.stubs(:id).returns
    feature_recipient.stubs(:owns_monkey?).returns(true)
    assert feature.enabled_for? feature_recipient
    
    feature_recipient.stubs(:owns_monkey?).returns(false)
    assert !feature.enabled_for?(feature_recipient)
  end

end
