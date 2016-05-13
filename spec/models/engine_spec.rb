# frozen_string_literal: true
require 'spec_helper'

describe Arturo::Engine do

  it 'includes feature availability' do
    expect(ActionController::Base).to be < Arturo::FeatureAvailability
  end

  it 'does not define availability methods as actions' do
    expect(BooksController.action_methods).to_not include('feature_enabled?')
    expect(BooksController.action_methods).to_not include('if_feature_enabled')
    expect(BooksController.action_methods).to_not include('feature_recipient')
  end

  it 'defines availability as a helper' do
    expect(Arturo::FeaturesController._helpers).to be < Arturo::FeatureAvailability
  end

  it 'includes filters in controllers' do
    expect(ActionController::Base).to be < Arturo::ControllerFilters
  end

  it 'does not define filter methods as actions' do
    expect(BooksController.action_methods).to_not include('on_feature_disabled')
  end

  it 'defines feature management as a helper' do
    expect(BooksController._helpers).to be < Arturo::FeatureManagement
  end

  it 'does not define feature management methods as actions' do
    expect(BooksController.action_methods).to_not include('may_manage_features?')
  end

end
