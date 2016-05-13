# frozen_string_literal: true
require 'spec_helper'

describe Arturo::NoSuchFeature do
  before do
    reset_translations!
  end

  let(:feature) { Arturo::NoSuchFeature.new(:an_unknown_feature) }

  it 'is not enabled' do
    expect(feature.enabled_for?(nil)).to be(false)
    expect(feature.enabled_for?(double('User', to_s: 'Saorse', id: 12))).to be(false)
  end

  it 'requires a symbol' do
    expect {
      Arturo::NoSuchFeature.new(nil)
    }.to raise_error(ArgumentError)
  end

  it 'responds to to_s' do
    expect(feature.to_s).to include(feature.name)
  end
end
