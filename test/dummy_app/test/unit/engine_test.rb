require File.expand_path('../../test_helper', __FILE__)

class EngineTest < ActiveSupport::TestCase

  def test_controllers_include_feature_availability
    assert ActionController::Base < Arturo::FeatureAvailability
  end

  def test_feature_availability_methods_are_not_actions
    assert !BooksController.action_methods.include?('feature_enabled?')
    assert !BooksController.action_methods.include?('if_feature_enabled')
  end

  def test_feature_availability_is_a_helper
    assert Arturo::FeaturesController._helpers < Arturo::FeatureAvailability
  end

  def test_controllers_include_filters
    assert ActionController::Base < Arturo::ControllerFilters
  end

  def test_controller_filter_methods_are_not_actions
    assert !BooksController.action_methods.include?('on_feature_disabled')
  end

end
