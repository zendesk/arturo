# frozen_string_literal: true

module WeatherAgent
  class Agent
    attr_reader :locations, :last_check, :results

    def initialize(locations: nil)
      @locations = Array(locations || WeatherAgent.location)
      @last_check = nil
      @results = {}
    end

    def run
      WeatherAgent.logger.info("Starting daily weather check at #{Time.now}")

      @last_check = Time.now
      @results = {}

      locations.each do |location|
        check_location(location)
      end

      log_summary
      results
    rescue StandardError => e
      WeatherAgent.logger.error("Weather check failed: #{e.message}")
      raise
    end

    def check_location(location)
      WeatherAgent.logger.info("Checking weather for: #{location}")

      forecast = Forecast.new(location).fetch
      results[location] = {
        success: true,
        forecast: forecast,
        checked_at: Time.now
      }

      WeatherAgent.logger.info(forecast.summary)
      forecast
    rescue APIError => e
      WeatherAgent.logger.error("Failed to fetch weather for #{location}: #{e.message}")
      results[location] = {
        success: false,
        error: e.message,
        checked_at: Time.now
      }
      nil
    end

    def add_location(location)
      @locations << location unless locations.include?(location)
    end

    def remove_location(location)
      @locations.delete(location)
    end

    def successful_checks
      results.select { |_, r| r[:success] }
    end

    def failed_checks
      results.reject { |_, r| r[:success] }
    end

    def all_successful?
      results.all? { |_, r| r[:success] }
    end

    def summary_report
      return "No checks have been performed yet" if results.empty?

      report = []
      report << "Weather Agent Report - #{last_check&.strftime('%Y-%m-%d %H:%M:%S')}"
      report << "=" * 60
      report << ""

      results.each do |location, result|
        if result[:success]
          forecast = result[:forecast]
          current = forecast.current_condition
          report << "#{forecast.location_name}"
          report << "-" * 40
          report << "  #{current[:description]}"
          report << "  Temperature: #{current[:temperature_c]}°C / #{current[:temperature_f]}°F"
          report << "  Humidity: #{current[:humidity]}%"
          report << ""
        else
          report << "#{location}: FAILED - #{result[:error]}"
          report << ""
        end
      end

      report << "=" * 60
      report << "Total: #{results.size} locations, #{successful_checks.size} successful, #{failed_checks.size} failed"

      report.join("\n")
    end

    private

    def log_summary
      WeatherAgent.logger.info("Weather check completed for #{results.size} location(s)")
      WeatherAgent.logger.info("Successful: #{successful_checks.size}, Failed: #{failed_checks.size}")
    end
  end
end
