module SyntageSdk
  class Configuration
    ENVIRONMENT_URLS = {
      development: 'https://api.sandbox.syntage.com',
      production: 'https://api.syntage.com'
    }.freeze

    DEFAULT_ENVIRONMENT = :production
    DEFAULT_TIMEOUT = 30
    DEFAULT_OPEN_TIMEOUT = 10

    attr_accessor :api_key, :timeout, :open_timeout
    attr_reader :environment
    attr_writer :base_url

    def initialize
      @api_key = ENV.fetch 'SYNTAGE_API_KEY', nil
      self.environment = ENV.fetch 'SYNTAGE_ENV', DEFAULT_ENVIRONMENT
      @base_url = nil
      @timeout = DEFAULT_TIMEOUT
      @open_timeout = DEFAULT_OPEN_TIMEOUT
    end

    def environment=(value)
      env = value.to_s.strip.downcase.to_sym

      unless ENVIRONMENT_URLS.key? env
        raise ConfigurationError,
              "Unknown environment #{value.inspect}. " \
              "Valid environments: #{ENVIRONMENT_URLS.keys.join ', '}."
      end

      @environment = env
    end

    def base_url
      @base_url || ENVIRONMENT_URLS.fetch(environment)
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
