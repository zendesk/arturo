# frozen_string_literal: true
require 'spec_helper'

describe 'Whilelist and Blacklist' do

  let(:feature) { create(:feature) }

  before do
    Arturo::Feature.whitelists.clear
    Arturo::Feature.blacklists.clear
  end

  after do
    Arturo::Feature.whitelists.clear
    Arturo::Feature.blacklists.clear
  end

  it 'overrides percent calculation with whitelist' do
    feature.deployment_percentage = 0
    Arturo::Feature.whitelist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(true)
  end

  it 'overrides percent calculation with blacklist' do
    feature.deployment_percentage = 100
    Arturo::Feature.blacklist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(false)
  end

  it 'prefers blacklist over whitelist' do
    Arturo::Feature.whitelist(feature.symbol) { |thing| true }
    Arturo::Feature.blacklist(feature.symbol) { |thing| true }
    expect(feature.enabled_for?(:a_thing)).to be(false)
  end

  it 'allow a whitelist or blacklist before the feature is created' do
    Arturo::Feature.whitelist(:does_not_exist) { |thing| thing == 'whitelisted' }
    Arturo::Feature.blacklist(:does_not_exist) { |thing| thing == 'blacklisted' }
    feature = create(:feature, symbol: :does_not_exist)
    expect(feature.enabled_for?('whitelisted')).to be(true)
    expect(feature.enabled_for?('blacklisted')).to be(false)
  end

  it 'works with global whitelisting' do
    feature.deployment_percentage = 0
    other_feature = create(:feature, deployment_percentage: 0)
    Arturo::Feature.whitelist { |feature, recipient| feature == other_feature }
    expect(feature.enabled_for?(:a_thing)).to be(false)
    expect(other_feature.enabled_for?(:a_thing)).to be(true)
  end

  it 'works with global blacklisting' do
    feature.deployment_percentage = 100
    other_feature = create(:feature, deployment_percentage: 100)
    Arturo::Feature.blacklist { |feature, recipient| feature == other_feature }
    expect(feature.enabled_for?(:a_thing)).to be(true)
    expect(other_feature.enabled_for?(:a_thing)).to be(false)
  end
end
