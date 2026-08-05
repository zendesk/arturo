# frozen_string_literal: true

require 'logger'
require 'weather_agent'
require 'webmock/rspec'

RSpec.describe WeatherAgent::Scheduler do
  let(:sample_response) do
    {
      'current_condition' => [
        {
          'temp_C' => '20',
          'temp_F' => '68',
          'FeelsLikeC' => '19',
          'FeelsLikeF' => '66',
          'humidity' => '50',
          'weatherDesc' => [{ 'value' => 'Clear' }],
          'windspeedKmph' => '10',
          'winddir16Point' => 'E',
          'uvIndex' => '4',
          'visibility' => '10',
          'pressure' => '1018'
        }
      ],
      'weather' => [
        {
          'date' => '2026-08-05',
          'maxtempC' => '25',
          'maxtempF' => '77',
          'mintempC' => '18',
          'mintempF' => '64',
          'uvIndex' => '5',
          'astronomy' => [{ 'sunrise' => '06:30 AM', 'sunset' => '07:30 PM' }],
          'hourly' => []
        }
      ],
      'nearest_area' => [
        {
          'areaName' => [{ 'value' => 'Test City' }],
          'country' => [{ 'value' => 'Test Country' }]
        }
      ]
    }
  end

  before do
    stub_request(:get, /wttr.in/)
      .to_return(status: 200, body: sample_response.to_json, headers: { 'Content-Type' => 'application/json' })

    WeatherAgent.logger = Logger.new(File::NULL)
  end

  describe '#initialize' do
    it 'uses default check time of 7:00' do
      scheduler = described_class.new
      expect(scheduler.check_hour).to eq(7)
      expect(scheduler.check_minute).to eq(0)
    end

    it 'accepts custom check time' do
      scheduler = described_class.new(check_hour: 9, check_minute: 30)
      expect(scheduler.check_hour).to eq(9)
      expect(scheduler.check_minute).to eq(30)
    end

    it 'creates an agent with the provided locations' do
      scheduler = described_class.new(locations: ['London', 'Paris'])
      expect(scheduler.agent.locations).to eq(['London', 'Paris'])
    end

    it 'starts in a non-running state' do
      scheduler = described_class.new
      expect(scheduler.running).to be false
    end
  end

  describe '#run_once' do
    let(:scheduler) { described_class.new(locations: 'London') }

    it 'runs the agent once' do
      result = scheduler.run_once
      expect(result).to be_a(Hash)
      expect(result.keys).to include('London')
    end
  end

  describe '#next_check_time' do
    let(:scheduler) { described_class.new(check_hour: 7, check_minute: 0) }

    context 'before the check time today' do
      it 'returns today at the check time' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 6, 0, 0))

        next_check = scheduler.next_check_time
        expect(next_check.hour).to eq(7)
        expect(next_check.min).to eq(0)
        expect(next_check.day).to eq(5)
      end
    end

    context 'after the check time today' do
      it 'returns tomorrow at the check time' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 10, 0, 0))

        next_check = scheduler.next_check_time
        expect(next_check.hour).to eq(7)
        expect(next_check.min).to eq(0)
        expect(next_check.day).to eq(6)
      end
    end
  end

  describe '#seconds_until_next_check' do
    let(:scheduler) { described_class.new(check_hour: 7, check_minute: 0) }

    it 'returns positive value before check time' do
      allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 6, 30, 0))

      seconds = scheduler.seconds_until_next_check
      expect(seconds).to eq(30 * 60)
    end

    it 'returns seconds until tomorrow when after check time' do
      allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 7, 30, 0))

      seconds = scheduler.seconds_until_next_check
      expect(seconds).to eq(23.5 * 60 * 60)
    end
  end

  describe '#should_check_today?' do
    let(:scheduler) { described_class.new(locations: 'London') }

    it 'returns true when no check has been performed' do
      expect(scheduler.should_check_today?).to be true
    end

    it 'returns false after a check has been performed today' do
      scheduler.run_once
      scheduler.instance_variable_set(:@last_check_date, Date.today)
      expect(scheduler.should_check_today?).to be false
    end

    it 'returns true when last check was yesterday' do
      scheduler.instance_variable_set(:@last_check_date, Date.today - 1)
      expect(scheduler.should_check_today?).to be true
    end
  end

  describe '#check_now?' do
    let(:scheduler) { described_class.new(check_hour: 7, check_minute: 0) }

    context 'at the exact check time' do
      it 'returns true' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 7, 0, 0))
        expect(scheduler.check_now?).to be true
      end
    end

    context 'within the check window (5 minutes)' do
      it 'returns true' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 7, 3, 0))
        expect(scheduler.check_now?).to be true
      end
    end

    context 'outside the check window' do
      it 'returns false' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 7, 10, 0))
        expect(scheduler.check_now?).to be false
      end
    end

    context 'wrong hour' do
      it 'returns false' do
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 8, 0, 0))
        expect(scheduler.check_now?).to be false
      end
    end

    context 'already checked today' do
      it 'returns false' do
        scheduler.instance_variable_set(:@last_check_date, Date.today)
        allow(Time).to receive(:now).and_return(Time.new(2026, 8, 5, 7, 0, 0))
        expect(scheduler.check_now?).to be false
      end
    end
  end

  describe '#stop' do
    let(:scheduler) { described_class.new }

    it 'sets running to false' do
      scheduler.instance_variable_set(:@running, true)
      scheduler.stop
      expect(scheduler.running).to be false
    end
  end
end
