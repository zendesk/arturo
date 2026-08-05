# frozen_string_literal: true

module WeatherAgent
  class Scheduler
    DEFAULT_CHECK_HOUR = 7
    DEFAULT_CHECK_MINUTE = 0

    attr_reader :agent, :check_hour, :check_minute, :running

    def initialize(locations: nil, check_hour: nil, check_minute: nil)
      @agent = Agent.new(locations: locations)
      @check_hour = check_hour || DEFAULT_CHECK_HOUR
      @check_minute = check_minute || DEFAULT_CHECK_MINUTE
      @running = false
      @last_check_date = nil
    end

    def start
      @running = true
      WeatherAgent.logger.info("Weather scheduler started. Daily checks at #{format_time}")

      run_loop
    end

    def stop
      @running = false
      WeatherAgent.logger.info("Weather scheduler stopped")
    end

    def run_once
      agent.run
    end

    def next_check_time
      now = Time.now
      next_check = Time.new(now.year, now.month, now.day, check_hour, check_minute, 0)

      if now >= next_check
        next_check += 86_400
      end

      next_check
    end

    def seconds_until_next_check
      [(next_check_time - Time.now).to_i, 0].max
    end

    def should_check_today?
      return true if @last_check_date.nil?

      @last_check_date != Date.today
    end

    def check_now?
      return false unless should_check_today?

      now = Time.now
      now.hour == check_hour && now.min >= check_minute && now.min < check_minute + 5
    end

    private

    def run_loop
      while running
        if check_now?
          perform_check
        end

        sleep(60)
      end
    end

    def perform_check
      WeatherAgent.logger.info("Performing scheduled weather check")
      @last_check_date = Date.today
      agent.run
    rescue StandardError => e
      WeatherAgent.logger.error("Scheduled check failed: #{e.message}")
    end

    def format_time
      format('%02d:%02d', check_hour, check_minute)
    end
  end
end
