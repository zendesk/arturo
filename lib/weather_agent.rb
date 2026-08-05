# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'time'

module WeatherAgent
  class Error < StandardError; end
  class APIError < Error; end
  class ConfigurationError < Error; end

  class << self
    attr_writer :logger, :location, :api_base_url

    def logger
      @logger ||= default_logger
    end

    def location
      @location || ENV.fetch('WEATHER_LOCATION', 'New York')
    end

    def api_base_url
      @api_base_url || 'https://wttr.in'
    end

    def configure
      yield self if block_given?
    end

    def check_forecast
      Forecast.new(location).fetch
    end

    def run_daily_check
      Agent.new.run
    end

    private

    def default_logger
      require 'logger'
      Logger.new($stdout, level: Logger::INFO)
    end
  end
end

require_relative 'weather_agent/forecast'
require_relative 'weather_agent/agent'
require_relative 'weather_agent/scheduler'
