# frozen_string_literal: true
require 'spec_helper'
require 'arturo/features_helper'

describe Arturo::FeatureCaching do
  Arturo::Feature.extend(Arturo::FeatureCaching)

  class StupidCache
    def initialize(enabled=true)
      @enabled = enabled
      @data = {}
    end

    def read(key)
      @data[key] if @enabled
    end

    def delete(key)
      @data.delete(key)
    end

    def write(key, value, options={})
      @data[key] = value
    end

    def clear
      @data.clear
    end
  end

  before do
    @feature = create(:feature)
    Arturo::Feature.cache_ttl = 30.minutes
    Arturo::Feature.feature_cache = Arturo::FeatureCaching::Cache.new
  end

  after do
    Arturo::Feature.cache_ttl = 0 # turn off for other tests
    Timecop.return
  end

  # Rails 4 calls all when calling maximum :/
  def lock_down_maximum
    m = Arturo::Feature.maximum(:updated_at)
    allow(Arturo::Feature).to receive(:maximum).and_return(m)
  end

  [Arturo::FeatureCaching::OneStrategy, Arturo::FeatureCaching::AllStrategy].each do |strategy|
    describe strategy do
      let(:feature_method) { strategy == Arturo::FeatureCaching::OneStrategy ? :where : :all }

      before do
        Arturo::Feature.feature_caching_strategy = strategy
      end

      it 'hits db on first load' do
        expect(Arturo::Feature).to receive(feature_method).and_return([@feature])

        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'caches missing features' do
        expect(Arturo::Feature).to receive(feature_method).and_return([])

        expect(Arturo::Feature.to_feature(:ramen)).to be_kind_of(Arturo::NoSuchFeature)
        expect(Arturo::Feature.to_feature(:ramen)).to be_kind_of(Arturo::NoSuchFeature)
        expect(Arturo::Feature.to_feature(:ramen)).to be_kind_of(Arturo::NoSuchFeature)
      end

      it 'works with other cache backends' do
        Arturo::Feature.feature_cache = StupidCache.new
        expect(Arturo::Feature).to receive(feature_method).and_return([@feature])

        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'works with inconsistent cache backend' do
        Arturo::Feature.feature_cache = StupidCache.new(false)
        expect(Arturo::Feature).to receive(feature_method).and_return([@feature]).twice

        Arturo::Feature.to_feature(@feature.symbol.to_sym)
        Arturo::Feature.to_feature(@feature.symbol.to_sym)
      end

      it 'can clear the cache' do
        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.feature_cache.clear
        expect(Arturo::Feature).to receive(feature_method).and_return([@feature])

        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'can turn off caching' do
        Arturo::Feature.cache_ttl = 0
        expect(Arturo::Feature).to receive(:where).and_return([@feature]).twice

        Arturo::Feature.to_feature(@feature.symbol)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'does not expire when inside cache ttl' do
        Arturo::Feature.to_feature(@feature.symbol)
        expect(Arturo::Feature).to_not receive(feature_method)

        Timecop.travel(Time.now + Arturo::Feature.cache_ttl - 5.seconds)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'expires when outside of cache ttl' do
        Arturo::Feature.to_feature(@feature.symbol)
        expect(Arturo::Feature).to receive(feature_method).and_return([@feature])

        Timecop.travel(Time.now + Arturo::Feature.cache_ttl * 12)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'expires cache on enable or disable' do
        Arturo.enable_feature!(@feature.symbol)
        expect(Arturo::Feature.to_feature(@feature.symbol).deployment_percentage).to eq(100)

        Arturo.disable_feature!(@feature.symbol)
        expect(Arturo::Feature.to_feature(@feature.symbol).deployment_percentage).to eq(0)
      end
    end
  end

  describe Arturo::FeatureCaching::AllStrategy do
    before do
      Arturo::Feature.feature_caching_strategy = Arturo::FeatureCaching::AllStrategy
    end

    it 'caches all features in one cache' do
      expect(Arturo::Feature).to_not receive(:maximum)
      expect(Arturo::Feature).to     receive(:all).and_return([])

      expect(Arturo::Feature.to_feature(:ramen)) .to be_kind_of(Arturo::NoSuchFeature)
      expect(Arturo::Feature.to_feature(:amen))  .to be_kind_of(Arturo::NoSuchFeature)
      expect(Arturo::Feature.to_feature(:laymen)).to be_kind_of(Arturo::NoSuchFeature)
    end

    it 'does not expire when inside cache ttl' do
      Arturo::Feature.to_feature(@feature.symbol)
      expect(Arturo::Feature).to_not receive(:maximum)
      expect(Arturo::Feature).to_not receive(:all)

      Timecop.travel(Time.now + Arturo::Feature.cache_ttl - 5.seconds)
      Arturo::Feature.to_feature(@feature.symbol)
    end

    it 'expires when only feature-cache is empty' do
      Arturo::Feature.to_feature(@feature.symbol)
      expect(Arturo::Feature).to_not receive(:maximum)
      expect(Arturo::Feature).to     receive(:all).and_return([])

      Arturo::Feature.feature_cache.delete('arturo.all')
      Arturo::Feature.to_feature(@feature.symbol)
    end

    describe 'when outside of cache ttl and fresh' do
      before do
        Arturo::Feature.to_feature(@feature.symbol)
        lock_down_maximum
        expect(Arturo::Feature).to_not receive(:all)

        Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
        Arturo::Feature.to_feature(@feature.symbol)
      end

      skip('does not expire')

      it "does not ask for updated_at after finding out it's fresh" do
        expect(Arturo::Feature).to_not receive(:maximum)
        Arturo::Feature.to_feature(@feature.symbol)
      end
    end

    describe 'when outside of cache ttl and stale' do
      let(:listener) { proc {} }

      before do
        Arturo::Feature.to_feature(@feature.symbol)
        @feature.touch
        lock_down_maximum
        Arturo::Feature.feature_caching_strategy.register_cache_update_listener(&listener)
        Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
      end

      after do
        Timecop.return
        Arturo::Feature.feature_caching_strategy.send(:cache_update_listeners).clear
      end

      it 'expires' do
        expect(Arturo::Feature).to receive(:all).and_return([@feature])
        Arturo::Feature.to_feature(@feature.symbol)
      end

      it 'triggers cache update listeners' do
        expect(listener).to receive(:call)
        Arturo::Feature.to_feature(@feature.symbol)
      end
    end

    it 'does not crash on nil updated_at' do
      @feature.class.where(id: @feature.id).update_all(updated_at: nil)
      create(:feature)
      expect {
        Arturo::Feature.to_feature(@feature.symbol)
        Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)
        Arturo::Feature.to_feature(@feature.symbol)
      }.to_not raise_error
    end

    describe 'database errors' do
      before do
        Arturo::Feature.to_feature(@feature.symbol)
        @feature.touch
        Timecop.travel(Time.now + Arturo::Feature.cache_ttl + 5.seconds)

        if ActiveRecord.version < Gem::Version.new("7.2")
          allow(ActiveRecord::Base).
            to receive(:connection).
            and_raise(ActiveRecord::ActiveRecordError)
        else
          allow(Arturo::Feature).
            to receive(:with_connection).
            and_raise(ActiveRecord::ActiveRecordError)
        end
      end

      context 'with extend_cache_on_failure enabled' do
        before { Arturo::Feature.extend_cache_on_failure = true }

        context 'with error checking origin changes' do
          it 'does not raise error' do
            expect { Arturo::Feature.to_feature(@feature.symbol) }.
              not_to raise_error
          end

          it 'extends the cache' do
            expect(Arturo::Feature.feature_caching_strategy).
              to receive(:mark_as_current!)
            Arturo::Feature.to_feature(@feature.symbol)
          end

          it 'returns the cached result' do
            expect(Arturo::Feature.to_feature(@feature.symbol)).to eq(@feature)
          end

          context 'with a cold cache' do
            before do
              Arturo::Feature.feature_caching_strategy.expire(Arturo::Feature.feature_cache, 'all')
            end

            it 'raises error' do
              expect { Arturo::Feature.to_feature(@feature.symbol) }.
                to raise_error(ActiveRecord::ActiveRecordError)
            end
          end
        end

        context 'with error while refetching origin' do
          before do
            allow(Arturo::Feature).to receive(:origin_changed?).and_return(true)
          end

          it 'does not raise error' do
            expect { Arturo::Feature.to_feature(@feature.symbol) }.
              not_to raise_error
          end

          it 'extends the cache' do
            expect(Arturo::Feature.feature_caching_strategy).
              to receive(:mark_as_current!)
            Arturo::Feature.to_feature(@feature.symbol)
          end

          it 'returns the cached result' do
            expect(Arturo::Feature.to_feature(@feature.symbol)).to eq(@feature)
          end

          context 'with a cold cache' do
            before do
              Arturo::Feature.feature_caching_strategy.expire(Arturo::Feature.feature_cache, 'all')
            end

            it 'raises error' do
              expect { Arturo::Feature.to_feature(@feature.symbol) }.
                to raise_error(ActiveRecord::ActiveRecordError)
            end
          end
        end
      end

      context 'with extend_cache_on_failure disabled' do
        before { Arturo::Feature.extend_cache_on_failure = false } 

        context 'with error checking origin changes' do
          it 'reraises the error' do
            expect { Arturo::Feature.to_feature(@feature.symbol) }.
              to raise_error(ActiveRecord::ActiveRecordError)
          end
        end

        context 'with error while refetching origin' do
          before do
            allow(Arturo::Feature).to receive(:origin_changed?).and_return(true)
          end

          it 'reraises the error' do
            expect { Arturo::Feature.to_feature(@feature.symbol) }.
              to raise_error(ActiveRecord::ActiveRecordError)
          end
        end
      end
    end
  end
end
