# frozen_string_literal: true
require 'spec_helper'
require 'arturo/features_helper'

describe Arturo::FeatureAvailability do
  let!(:current_user) { double('CurrentUser') }
  let!(:helper) { double('Helper', current_user: current_user).tap { |h| h.extend described_class } }

  let(:feature) { create(:feature) }
  let(:block)   { -> { 'Content that requires a feature' } }

  describe 'if_feature_enabled' do
    it 'does not call the block with non existent feature' do
      expect(block).to_not receive(:call)
      expect(helper.if_feature_enabled(:nonexistent, &block)).to be_nil
    end

    it 'uses feature recipient' do
      expect(feature).to receive(:enabled_for?).with(current_user)
      helper.if_feature_enabled(feature, &block)
    end

    it 'does not call the block with disabled feature' do
      allow(feature).to receive(:enabled_for?).and_return(false)
      expect(block).to_not receive(:call)
      expect(helper.if_feature_enabled(feature, &block)).to be_nil
    end

    it 'calls the block with enabled feature' do
      allow(feature).to receive(:enabled_for?).and_return(true)
      expect(block).to receive(:call).and_return('result')
      expect(helper.if_feature_enabled(feature, &block)).to eq('result')
    end
  end
end
