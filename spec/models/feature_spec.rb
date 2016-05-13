# frozen_string_literal: true
require 'spec_helper'

describe Arturo::Feature do

  before do
    reset_translations!
  end

  let(:feature) { create(:feature) }
  let(:bunch_of_things) do
    (1..2000).to_a.map do |i|
      double('Thing', id: i)
    end
  end

  it 'responds to to_feature' do
    expect(::Arturo::Feature.to_feature(feature)).to eq(feature)
    expect(::Arturo::Feature.to_feature(feature.symbol)).to eq(feature)
    expect(::Arturo::Feature.to_feature(:does_not_exist)).to be_a(Arturo::NoSuchFeature)
  end

  it 'responds to find_feature' do
    expect(::Arturo::Feature.find_feature(feature)).to eq(feature)
    expect(::Arturo::Feature.find_feature(feature.symbol)).to eq(feature)
    expect(::Arturo::Feature.find_feature(:does_not_exist)).to be_nil
  end

  it 'finds existent features with feature_enabled_for' do
    feature.update_attribute(:deployment_percentage, 100)
    recipient = double('User', to_s: 'Paula', id: 12)
    expect(::Arturo.feature_enabled_for?(feature.symbol, recipient)).to be(true), "#{feature} should be enabled for #{recipient}"
  end

  it 'does not finds non existent features with feature_enabled_for' do
    expect(::Arturo.feature_enabled_for?(:does_not_exist, 'Paula')).to be(false)
  end

  it 'requires a symbol' do
    feature.symbol = nil
    expect(feature).to_not be_valid
    expect(feature.errors[:symbol]).to be_present
  end

  it 'responds to last_updated_at' do
    Arturo::Feature.delete_all

    Timecop.freeze(Time.local(2008, 9, 1, 12, 0, 0)) { create(:feature) }
    updated_at = Time.local(2011, 9, 1, 12, 0, 0)

    Timecop.freeze(updated_at) { create(:feature) }
    expect(Arturo::Feature.last_updated_at).to eq(updated_at)
  end

  it 'responds to last_updated_at with no features' do
    Arturo::Feature.delete_all
    expect(Arturo::Feature.last_updated_at).to be_nil
  end

  # regression
  # @see https://github.com/zendesk/arturo/issues/7
  it 'does not overwrite deployment_percentage on create' do
    new_feature = ::Arturo::Feature.create('symbol' => :foo, 'deployment_percentage' => 37)
    expect(new_feature.deployment_percentage.to_s).to eq('37')
  end

  it 'requires a deployment percentage' do
    feature.deployment_percentage = nil
    expect(feature).to_not be_valid
    expect(feature.errors[:deployment_percentage]).to be_present
  end

  it 'has a readonly symbol' do
    original_symbol = feature.symbol
    feature.symbol = :foo_bar
    feature.save
    expect(feature.reload.symbol.to_sym).to eq(original_symbol.to_sym)
  end

  it 'has a sane default for name' do
    feature.symbol = :foo_bar
    expect(feature.name).to eq('Foo Bar')
  end

  it 'uses names with internationalization when available' do
    define_translation("arturo.feature.#{feature.symbol}", 'Happy Feature')
    expect(feature.name).to eq('Happy Feature')
  end

  it 'sets deployment percentagle to 0 by default' do
    expect(::Arturo::Feature.new.deployment_percentage).to eq(0)
  end

  describe 'enabled_for?' do
    it 'returns false if thing is nil' do
      feature.deployment_percentage = 100
      expect(feature.enabled_for?(nil)).to be(false)
    end

    it 'returns false for all things when deployment percentage is nil' do
      feature.deployment_percentage = 0
      bunch_of_things.each do |t|
        expect(feature.enabled_for?(t)).to be(false)
      end
    end

    it 'returns true for all non nil things when deployment percentage is 100' do
      feature.deployment_percentage = 100
      bunch_of_things.each do |t|
        expect(feature.enabled_for?(t)).to be(true)
      end
    end

    it 'returns true for about deployment percentage percent of things' do
      feature.deployment_percentage = 37
      yes = 0
      bunch_of_things.each { |t| yes += 1 if feature.enabled_for?(t) }
      expect(yes).to be_within(0.02 * bunch_of_things.length).of(0.37 * bunch_of_things.length)
    end

    it 'returns false for things with nil id and not 100' do
      feature.deployment_percentage = 99
      expect(feature.enabled_for?(double('ThingWithNilId', id: nil))).to be(false)
    end

    it 'returns false for things with nil id and 100' do
      feature.deployment_percentage = 100
      expect(feature.enabled_for?(double('ThingWithNilId', id: nil))).to be(true)
    end

    it 'is not identical across features' do
      foo = create(:feature, symbol: :foo, deployment_percentage: 55)
      bar = create(:feature, symbol: :bar, deployment_percentage: 55)
      has_foo = bunch_of_things.map { |t| foo.enabled_for?(t) }
      has_bar = bunch_of_things.map { |t| bar.enabled_for?(t) }
      expect(has_bar).to_not eq(has_foo)
    end
  end

  it 'responds do to_s' do
    expect(feature.to_s).to include(feature.name)
  end

  it 'responds to to_param' do
    expect(feature.to_param).to match(%r{^#{feature.id}-})
  end
end
