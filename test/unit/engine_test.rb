# frozen_string_literal: true
require File.expand_path('../../test_helper', __FILE__)

class EngineTest < ActiveSupport::TestCase

  def test_controllers_include_feature_availability
    assert ActionController::Base < Arturo::FeatureAvailability
  end

  def test_feature_availability_methods_are_not_actions
    refute BooksController.action_methods.include?('feature_enabled?')
    refute BooksController.action_methods.include?('if_feature_enabled')
    refute BooksController.action_methods.include?('feature_recipient')
  end

  def test_feature_availability_is_a_helper
    assert Arturo::FeaturesController._helpers < Arturo::FeatureAvailability
  end

  def test_controllers_include_filters
    assert ActionController::Base < Arturo::ControllerFilters
  end

  def test_controller_filter_methods_are_not_actions
    refute BooksController.action_methods.include?('on_feature_disabled')
  end

  def test_feature_management_is_a_helper
    assert BooksController._helpers < Arturo::FeatureManagement
  end

  def test_feature_management_methods_are_not_actions
    refute BooksController.action_methods.include?('may_manage_features?')
  end

end
