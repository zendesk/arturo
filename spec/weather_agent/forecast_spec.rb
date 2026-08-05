# frozen_string_literal: true

require 'weather_agent'
require 'webmock/rspec'

RSpec.describe WeatherAgent::Forecast do
  let(:location) { 'London' }
  let(:forecast) { described_class.new(location) }

  let(:sample_response) do
    {
      'current_condition' => [
        {
          'temp_C' => '15',
          'temp_F' => '59',
          'FeelsLikeC' => '14',
          'FeelsLikeF' => '57',
          'humidity' => '72',
          'weatherDesc' => [{ 'value' => 'Partly cloudy' }],
          'windspeedKmph' => '20',
          'winddir16Point' => 'SW',
          'uvIndex' => '3',
          'visibility' => '10',
          'pressure' => '1015'
        }
      ],
      'weather' => [
        {
          'date' => '2026-08-05',
          'maxtempC' => '22',
          'maxtempF' => '72',
          'mintempC' => '14',
          'mintempF' => '57',
          'uvIndex' => '4',
          'astronomy' => [
            { 'sunrise' => '05:30 AM', 'sunset' => '08:45 PM' }
          ],
          'hourly' => [
            {
              'time' => '0',
              'tempC' => '14',
              'tempF' => '57',
              'weatherDesc' => [{ 'value' => 'Clear' }],
              'chanceofrain' => '5',
              'humidity' => '75'
            },
            {
              'time' => '1200',
              'tempC' => '20',
              'tempF' => '68',
              'weatherDesc' => [{ 'value' => 'Sunny' }],
              'chanceofrain' => '0',
              'humidity' => '55'
            }
          ]
        },
        {
          'date' => '2026-08-06',
          'maxtempC' => '24',
          'maxtempF' => '75',
          'mintempC' => '16',
          'mintempF' => '61',
          'uvIndex' => '5',
          'astronomy' => [
            { 'sunrise' => '05:32 AM', 'sunset' => '08:43 PM' }
          ],
          'hourly' => []
        }
      ],
      'nearest_area' => [
        {
          'areaName' => [{ 'value' => 'London' }],
          'country' => [{ 'value' => 'United Kingdom' }]
        }
      ]
    }
  end

  before do
    stub_request(:get, /wttr.in/)
      .to_return(status: 200, body: sample_response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#fetch' do
    it 'returns self' do
      expect(forecast.fetch).to eq(forecast)
    end

    it 'sets fetched_at' do
      forecast.fetch
      expect(forecast.fetched_at).to be_within(1).of(Time.now)
    end

    it 'stores the data' do
      forecast.fetch
      expect(forecast.data).to eq(sample_response)
    end

    context 'when API returns an error' do
      before do
        stub_request(:get, /wttr.in/)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an APIError' do
        expect { forecast.fetch }.to raise_error(WeatherAgent::APIError, /500/)
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:get, /wttr.in/).to_timeout
      end

      it 'raises an APIError' do
        expect { forecast.fetch }.to raise_error(WeatherAgent::APIError, /connect/)
      end
    end
  end

  describe '#current_condition' do
    before { forecast.fetch }

    it 'returns current weather conditions' do
      current = forecast.current_condition

      expect(current[:temperature_c]).to eq(15)
      expect(current[:temperature_f]).to eq(59)
      expect(current[:feels_like_c]).to eq(14)
      expect(current[:humidity]).to eq(72)
      expect(current[:description]).to eq('Partly cloudy')
      expect(current[:wind_speed_kmph]).to eq(20)
      expect(current[:wind_direction]).to eq('SW')
      expect(current[:uv_index]).to eq(3)
    end
  end

  describe '#daily_forecasts' do
    before { forecast.fetch }

    it 'returns an array of daily forecasts' do
      forecasts = forecast.daily_forecasts

      expect(forecasts.length).to eq(2)
      expect(forecasts[0][:date]).to eq(Date.new(2026, 8, 5))
      expect(forecasts[0][:max_temp_c]).to eq(22)
      expect(forecasts[0][:min_temp_c]).to eq(14)
      expect(forecasts[0][:sunrise]).to eq('05:30 AM')
      expect(forecasts[0][:sunset]).to eq('08:45 PM')
    end

    it 'includes hourly forecasts' do
      hourly = forecast.daily_forecasts[0][:hourly]

      expect(hourly.length).to eq(2)
      expect(hourly[0][:time]).to eq('00:00')
      expect(hourly[0][:temp_c]).to eq(14)
      expect(hourly[1][:time]).to eq('12:00')
      expect(hourly[1][:temp_c]).to eq(20)
    end
  end

  describe '#today' do
    before { forecast.fetch }

    it 'returns the first daily forecast' do
      expect(forecast.today[:date]).to eq(Date.new(2026, 8, 5))
    end
  end

  describe '#tomorrow' do
    before { forecast.fetch }

    it 'returns the second daily forecast' do
      expect(forecast.tomorrow[:date]).to eq(Date.new(2026, 8, 6))
    end
  end

  describe '#location_name' do
    before { forecast.fetch }

    it 'returns the location from nearest_area' do
      expect(forecast.location_name).to eq('London, United Kingdom')
    end
  end

  describe '#summary' do
    before { forecast.fetch }

    it 'returns a human-readable summary' do
      summary = forecast.summary

      expect(summary).to include('Weather Forecast for London, United Kingdom')
      expect(summary).to include('Temperature: 15°C')
      expect(summary).to include('Partly cloudy')
      expect(summary).to include('High: 22°C')
      expect(summary).to include('Low: 14°C')
    end
  end

  describe '#to_h' do
    before { forecast.fetch }

    it 'returns a hash representation' do
      hash = forecast.to_h

      expect(hash[:location]).to eq('London, United Kingdom')
      expect(hash[:current]).to be_a(Hash)
      expect(hash[:forecast]).to be_an(Array)
      expect(hash[:fetched_at]).to be_a(String)
    end
  end

  describe '#to_json' do
    before { forecast.fetch }

    it 'returns valid JSON' do
      json = forecast.to_json
      parsed = JSON.parse(json)

      expect(parsed['location']).to eq('London, United Kingdom')
    end
  end
end
