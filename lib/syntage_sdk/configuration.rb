# frozen_string_literal: true

module SyntageSdk
  class Configuration
    ENVIRONMENT_URLS = {
      development: 'https://api.sandbox.syntage.com',
      production: 'https://api.syntage.com'
    }

    DEFAULT_ENVIRONMENT = :production
    DEFAULT_TIMEOUT = 30
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_MAX_RETRIES = 2

    def initialize
      @settings = {
        api_key: ENV.fetch('SYNTAGE_API_KEY', nil),
        base_url: nil,
        timeout: DEFAULT_TIMEOUT,
        open_timeout: DEFAULT_OPEN_TIMEOUT,
        max_retries: DEFAULT_MAX_RETRIES
      }
      self.environment = ENV.fetch 'SYNTAGE_ENV', DEFAULT_ENVIRONMENT
    end

    def api_key
      @settings[:api_key]
    end

    def api_key=(value)
      @settings[:api_key] = value
    end

    def timeout
      @settings[:timeout]
    end

    def timeout=(value)
      @settings[:timeout] = value
    end

    def open_timeout
      @settings[:open_timeout]
    end

    def open_timeout=(value)
      @settings[:open_timeout] = value
    end

    def max_retries
      @settings[:max_retries]
    end

    def max_retries=(value)
      @settings[:max_retries] = value
    end

    def environment
      @settings[:environment]
    end

    def environment=(value)
      env = value.to_s.strip.downcase.to_sym

      unless ENVIRONMENT_URLS.key? env
        raise ConfigurationError,
              "Unknown environment #{value.inspect}. " \
              "Valid environments: #{ENVIRONMENT_URLS.keys.join ', '}."
      end

      @settings[:environment] = env
    end

    def base_url=(value)
      @settings[:base_url] = value
    end

    def base_url
      @settings[:base_url] || ENVIRONMENT_URLS.fetch(environment)
    end

    def headers
      {
        'X-API-Key' => fetch_api_key,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    private

    def fetch_api_key
      key = api_key.to_s.strip
      return key unless key.empty?

      raise ConfigurationError,
            'Missing Syntage API key. Set it with ' \
            'SyntageSdk.configure { |c| c.api_key = "..." } ' \
            'or the SYNTAGE_API_KEY environment variable.'
    end
  end
end
