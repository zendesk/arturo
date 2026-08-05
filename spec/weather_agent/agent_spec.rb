# frozen_string_literal: true

require 'logger'
require 'weather_agent'
require 'webmock/rspec'

RSpec.describe WeatherAgent::Agent do
  let(:sample_response) do
    {
      'current_condition' => [
        {
          'temp_C' => '18',
          'temp_F' => '64',
          'FeelsLikeC' => '17',
          'FeelsLikeF' => '63',
          'humidity' => '65',
          'weatherDesc' => [{ 'value' => 'Sunny' }],
          'windspeedKmph' => '15',
          'winddir16Point' => 'N',
          'uvIndex' => '5',
          'visibility' => '10',
          'pressure' => '1020'
        }
      ],
      'weather' => [
        {
          'date' => '2026-08-05',
          'maxtempC' => '25',
          'maxtempF' => '77',
          'mintempC' => '15',
          'mintempF' => '59',
          'uvIndex' => '6',
          'astronomy' => [{ 'sunrise' => '06:00 AM', 'sunset' => '08:00 PM' }],
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
    it 'accepts a single location' do
      agent = described_class.new(locations: 'Paris')
      expect(agent.locations).to eq(['Paris'])
    end

    it 'accepts multiple locations' do
      agent = described_class.new(locations: ['Paris', 'London'])
      expect(agent.locations).to eq(['Paris', 'London'])
    end

    it 'uses default location when none provided' do
      WeatherAgent.location = 'Default City'
      agent = described_class.new
      expect(agent.locations).to include('Default City')
    end
  end

  describe '#run' do
    let(:agent) { described_class.new(locations: ['London', 'Paris']) }

    it 'checks all locations' do
      agent.run
      expect(agent.results.keys).to contain_exactly('London', 'Paris')
    end

    it 'sets last_check time' do
      agent.run
      expect(agent.last_check).to be_within(1).of(Time.now)
    end

    it 'returns the results' do
      result = agent.run
      expect(result).to eq(agent.results)
    end

    context 'when a location fails' do
      before do
        stub_request(:get, /wttr.in\/Paris/)
          .to_return(status: 500, body: 'Error')
        stub_request(:get, /wttr.in\/London/)
          .to_return(status: 200, body: sample_response.to_json)
      end

      it 'continues to other locations' do
        agent.run
        expect(agent.results['London'][:success]).to be true
        expect(agent.results['Paris'][:success]).to be false
      end

      it 'records the error' do
        agent.run
        expect(agent.results['Paris'][:error]).to include('500')
      end
    end
  end

  describe '#check_location' do
    let(:agent) { described_class.new(locations: 'London') }

    it 'returns a Forecast object' do
      result = agent.check_location('London')
      expect(result).to be_a(WeatherAgent::Forecast)
    end

    it 'stores the result' do
      agent.check_location('London')
      expect(agent.results['London'][:success]).to be true
      expect(agent.results['London'][:forecast]).to be_a(WeatherAgent::Forecast)
    end
  end

  describe '#add_location' do
    let(:agent) { described_class.new(locations: 'London') }

    it 'adds a new location' do
      agent.add_location('Paris')
      expect(agent.locations).to contain_exactly('London', 'Paris')
    end

    it 'does not add duplicates' do
      agent.add_location('London')
      expect(agent.locations).to eq(['London'])
    end
  end

  describe '#remove_location' do
    let(:agent) { described_class.new(locations: ['London', 'Paris']) }

    it 'removes a location' do
      agent.remove_location('Paris')
      expect(agent.locations).to eq(['London'])
    end
  end

  describe '#successful_checks' do
    let(:agent) { described_class.new(locations: ['London', 'Paris']) }

    before do
      stub_request(:get, /wttr.in\/Paris/)
        .to_return(status: 500, body: 'Error')
      stub_request(:get, /wttr.in\/London/)
        .to_return(status: 200, body: sample_response.to_json)
      agent.run
    end

    it 'returns only successful checks' do
      expect(agent.successful_checks.keys).to eq(['London'])
    end
  end

  describe '#failed_checks' do
    let(:agent) { described_class.new(locations: ['London', 'Paris']) }

    before do
      stub_request(:get, /wttr.in\/Paris/)
        .to_return(status: 500, body: 'Error')
      stub_request(:get, /wttr.in\/London/)
        .to_return(status: 200, body: sample_response.to_json)
      agent.run
    end

    it 'returns only failed checks' do
      expect(agent.failed_checks.keys).to eq(['Paris'])
    end
  end

  describe '#all_successful?' do
    let(:agent) { described_class.new(locations: ['London', 'Paris']) }

    it 'returns true when all checks succeed' do
      agent.run
      expect(agent.all_successful?).to be true
    end

    it 'returns false when any check fails' do
      stub_request(:get, /wttr.in\/Paris/)
        .to_return(status: 500, body: 'Error')
      agent.run
      expect(agent.all_successful?).to be false
    end
  end

  describe '#summary_report' do
    let(:agent) { described_class.new(locations: 'London') }

    context 'before any checks' do
      it 'returns a message indicating no checks' do
        expect(agent.summary_report).to include('No checks have been performed')
      end
    end

    context 'after running checks' do
      before { agent.run }

      it 'includes the location name' do
        expect(agent.summary_report).to include('Test City, Test Country')
      end

      it 'includes current conditions' do
        report = agent.summary_report
        expect(report).to include('Sunny')
        expect(report).to include('18°C')
      end

      it 'includes success/failure summary' do
        expect(agent.summary_report).to include('1 successful')
      end
    end
  end
end
