# frozen_string_literal: true
module Arturo
  # A Rack middleware that requires a feature to be present. By default,
  # checks feature availability against an `arturo.recipient` object
  # in the `env`. If that object is missing, this middleware always fails,
  # even if the feature is available for everyone.
  #
  # ## Usage
  #
  #     use Arturo::Middleware, :feature => :foo
  #
  # ## Options
  #
  #  * feature -- the name of the feature to require, as a Symbol; required
  #
  #  * recipient -- the key in the `env` hash under which the feature
  #                 recipient can be found; defaults to "arturo.recipient".
  #  * on_unavailable -- a Rack-like object
  #                      (has `#call(Hash) -> [status, headers, body]`) that
  #                      is called when the feature is unavailable; defaults
  #                      to returning `[ 404, {}, ['Not Found'] ]`.
  class Middleware

    MISSING_FEATURE_ERROR = "Cannot create an Arturo::Middleware without a :feature"

    DEFAULT_RECIPIENT_KEY = 'arturo.recipient'

    DEFAULT_ON_UNAVAILABLE = lambda { |env| [ 404, {}, ['Not Found'] ] }

    def initialize(app, options = {})
      @app = app
      @feature = options[:feature]
      raise ArgumentError.new(MISSING_FEATURE_ERROR) unless @feature
      @recipient_key = options[:recipient] || DEFAULT_RECIPIENT_KEY
      @on_unavailable = options[:on_unavailable] || DEFAULT_ON_UNAVAILABLE
    end

    def call(env)
      if enabled_for_recipient?(env)
        @app.call(env)
      else
        fail(env)
      end
    end

    private

    def enabled_for_recipient?(env)
      ::Arturo.feature_enabled_for?(@feature, recipient(env))
    end

    def recipient(env)
      env[@recipient_key]
    end

    def fail(env)
      @on_unavailable.call(env)
    end

  end
end
