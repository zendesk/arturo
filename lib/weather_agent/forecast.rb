# frozen_string_literal: true

module WeatherAgent
  class Forecast
    attr_reader :location, :data, :fetched_at

    def initialize(location)
      @location = location
      @data = nil
      @fetched_at = nil
    end

    def fetch
      uri = build_uri
      response = make_request(uri)
      parse_response(response)
      self
    end

    def current_condition
      return nil unless data

      condition = data.dig('current_condition', 0)
      return nil unless condition

      {
        temperature_c: condition['temp_C'].to_i,
        temperature_f: condition['temp_F'].to_i,
        feels_like_c: condition['FeelsLikeC'].to_i,
        feels_like_f: condition['FeelsLikeF'].to_i,
        humidity: condition['humidity'].to_i,
        description: condition.dig('weatherDesc', 0, 'value'),
        wind_speed_kmph: condition['windspeedKmph'].to_i,
        wind_direction: condition['winddir16Point'],
        uv_index: condition['uvIndex'].to_i,
        visibility_km: condition['visibility'].to_i,
        pressure_mb: condition['pressure'].to_i
      }
    end

    def daily_forecasts
      return [] unless data

      (data['weather'] || []).map do |day|
        {
          date: Date.parse(day['date']),
          max_temp_c: day['maxtempC'].to_i,
          max_temp_f: day['maxtempF'].to_i,
          min_temp_c: day['mintempC'].to_i,
          min_temp_f: day['mintempF'].to_i,
          sunrise: day.dig('astronomy', 0, 'sunrise'),
          sunset: day.dig('astronomy', 0, 'sunset'),
          uv_index: day['uvIndex'].to_i,
          hourly: parse_hourly(day['hourly'])
        }
      end
    end

    def today
      daily_forecasts.first
    end

    def tomorrow
      daily_forecasts[1]
    end

    def summary
      return "No forecast data available" unless data

      current = current_condition
      today_forecast = today

      return "Unable to parse forecast data" unless current && today_forecast

      <<~SUMMARY
        Weather Forecast for #{location_name}
        #{'-' * 40}
        Current Conditions (#{fetched_at&.strftime('%Y-%m-%d %H:%M')})
          Temperature: #{current[:temperature_c]}°C (#{current[:temperature_f]}°F)
          Feels Like: #{current[:feels_like_c]}°C (#{current[:feels_like_f]}°F)
          Conditions: #{current[:description]}
          Humidity: #{current[:humidity]}%
          Wind: #{current[:wind_speed_kmph]} km/h #{current[:wind_direction]}
          UV Index: #{current[:uv_index]}

        Today's Forecast (#{today_forecast[:date]})
          High: #{today_forecast[:max_temp_c]}°C (#{today_forecast[:max_temp_f]}°F)
          Low: #{today_forecast[:min_temp_c]}°C (#{today_forecast[:min_temp_f]}°F)
          Sunrise: #{today_forecast[:sunrise]}
          Sunset: #{today_forecast[:sunset]}
      SUMMARY
    end

    def location_name
      return location unless data

      nearest = data.dig('nearest_area', 0)
      return location unless nearest

      city = nearest.dig('areaName', 0, 'value')
      country = nearest.dig('country', 0, 'value')
      [city, country].compact.join(', ')
    end

    def to_h
      {
        location: location_name,
        fetched_at: fetched_at&.iso8601,
        current: current_condition,
        forecast: daily_forecasts
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    private

    def build_uri
      encoded_location = URI.encode_www_form_component(location)
      URI.parse("#{WeatherAgent.api_base_url}/#{encoded_location}?format=j1")
    end

    def make_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'WeatherAgent/1.0'
      request['Accept'] = 'application/json'

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise APIError, "Weather API returned #{response.code}: #{response.message}"
      end

      response.body
    rescue Timeout::Error, Errno::ECONNREFUSED, SocketError => e
      raise APIError, "Failed to connect to weather API: #{e.message}"
    end

    def parse_response(body)
      @data = JSON.parse(body)
      @fetched_at = Time.now
    rescue JSON::ParserError => e
      raise APIError, "Failed to parse weather API response: #{e.message}"
    end

    def parse_hourly(hourly_data)
      return [] unless hourly_data

      hourly_data.map do |hour|
        time_val = hour['time'].to_i
        hour_num = time_val / 100

        {
          time: format('%02d:00', hour_num),
          temp_c: hour['tempC'].to_i,
          temp_f: hour['tempF'].to_i,
          description: hour.dig('weatherDesc', 0, 'value'),
          chance_of_rain: hour['chanceofrain'].to_i,
          humidity: hour['humidity'].to_i
        }
      end
    end
  end
end
