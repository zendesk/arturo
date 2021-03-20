# frozen_string_literal: true
require 'spec_helper'

describe 'Grantlist and Blocklist' do

  let(:feature) { create(:feature) }

  before do
    Arturo::Feature.grantlists.clear
    Arturo::Feature.blocklists.clear
  end

  it 'overrides percent calculation with grantlist' do
    feature.deployment_percentage = 0
    Arturo::Feature.grantlist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(true)
  end

  it 'overrides percent calculation with blocklist' do
    feature.deployment_percentage = 100
    Arturo::Feature.blocklist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(false)
  end

  it 'prefers blocklist over grantlist' do
    Arturo::Feature.grantlist(feature.symbol) { |thing| true }
    Arturo::Feature.blocklist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(false)
  end

  it 'allow a grantlist or blocklist before the feature is created' do
    Arturo::Feature.grantlist(:does_not_exist) { |thing| thing == 'grantlisted' }
    Arturo::Feature.blocklist(:does_not_exist) { |thing| thing == 'blocklisted' }
    feature = create(:feature, symbol: :does_not_exist)
    expect(feature.enabled_for?('grantlisted')).to be(true)
    expect(feature.enabled_for?('blocklisted')).to be(false)
  end

  it 'works with global grantlisting' do
    feature.deployment_percentage = 0
    other_feature = create(:feature, deployment_percentage: 0)
    Arturo::Feature.grantlist { |feature, recipient| feature == other_feature }
    expect(feature.enabled_for?(:a_thing)).to be(false)
    expect(other_feature.enabled_for?(:a_thing)).to be(true)
  end

  it 'works with global blocklisting' do
    feature.deployment_percentage = 100
    other_feature = create(:feature, deployment_percentage: 100)
    Arturo::Feature.blocklist { |feature, recipient| feature == other_feature }
    expect(feature.enabled_for?(:a_thing)).to be(true)
    expect(other_feature.enabled_for?(:a_thing)).to be(false)
  end
end
