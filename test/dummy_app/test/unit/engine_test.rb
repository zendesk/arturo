require File.expand_path('../../test_helper', __FILE__)

class EngineTest < ActiveSupport::TestCase

  def test_controllers_include_feature_availability
    assert ActionController::Base < Arturo::FeatureAvailability
  end

  def test_feature_availability_is_a_helper
    assert Arturo::FeaturesController._helpers < Arturo::FeatureAvailability
  end

end
