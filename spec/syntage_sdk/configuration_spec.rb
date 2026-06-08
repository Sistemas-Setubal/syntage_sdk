require 'syntage_sdk'

RSpec.describe SyntageSdk::Configuration do
  subject(:configuration) { described_class.new }

  describe 'defaults' do
    around do |example|
      original = ENV.fetch 'SYNTAGE_API_KEY', nil
      env = ENV.fetch 'SYNTAGE_ENV', nil
      ENV.delete 'SYNTAGE_API_KEY'
      ENV.delete 'SYNTAGE_ENV'
      example.run
      ENV['SYNTAGE_API_KEY'] = original unless original.nil?
      ENV['SYNTAGE_ENV'] = env unless env.nil?
    end

    it 'has no api_key when the environment variable is absent' do
      expect(configuration.api_key).to be_nil
    end

    it 'defaults to the production environment' do
      expect(configuration.environment).to eq(described_class::DEFAULT_ENVIRONMENT)
    end

    it 'resolves base_url from the default environment' do
      expect(configuration.base_url).to eq(described_class::ENVIRONMENT_URLS.fetch(:production))
    end

    it 'uses the default timeouts' do
      expect(configuration).to have_attributes(
        timeout: described_class::DEFAULT_TIMEOUT,
        open_timeout: described_class::DEFAULT_OPEN_TIMEOUT
      )
    end
  end

  describe 'reading from the environment' do
    around do |example|
      api_key = ENV.fetch 'SYNTAGE_API_KEY', nil
      env = ENV.fetch 'SYNTAGE_ENV', nil
      ENV['SYNTAGE_API_KEY'] = 'sk_env_123'
      ENV['SYNTAGE_ENV'] = 'development'
      example.run
      api_key.nil? ? ENV.delete('SYNTAGE_API_KEY') : ENV['SYNTAGE_API_KEY'] = api_key
      env.nil? ? ENV.delete('SYNTAGE_ENV') : ENV['SYNTAGE_ENV'] = env
    end

    it 'reads the api_key from SYNTAGE_API_KEY' do
      expect(configuration.api_key).to eq('sk_env_123')
    end

    it 'reads the environment from SYNTAGE_ENV' do
      expect(configuration.environment).to eq(:development)
    end
  end

  describe '#environment=' do
    it 'switches the base_url to the development host' do
      configuration.environment = :development

      expect(configuration.base_url).to eq('https://api.sandbox.syntage.com')
    end

    it 'switches the base_url to the production host' do
      configuration.environment = :production

      expect(configuration.base_url).to eq('https://api.syntage.com')
    end

    it 'accepts the environment as a string' do
      configuration.environment = 'Development'

      expect(configuration.environment).to eq(:development)
    end

    it 'raises ConfigurationError on an unknown environment' do
      expect { configuration.environment = :staging }.to raise_error(
        SyntageSdk::ConfigurationError, /Unknown environment/
      )
    end
  end

  describe '#base_url' do
    it 'honours an explicit override regardless of environment' do
      configuration.environment = :production
      configuration.base_url = 'http://localhost:3000'

      expect(configuration.base_url).to eq('http://localhost:3000')
    end
  end

  describe 'writable timeouts' do
    it 'allows overriding the read timeout' do
      configuration.timeout = 5

      expect(configuration.timeout).to eq(5)
    end

    it 'allows overriding the open timeout' do
      configuration.open_timeout = 2

      expect(configuration.open_timeout).to eq(2)
    end
  end

  describe '#headers' do
    it 'includes the X-API-Key authentication header' do
      configuration.api_key = 'sk_live_abc'

      expect(configuration.headers).to include('X-API-Key' => 'sk_live_abc')
    end

    it 'requests and accepts JSON' do
      configuration.api_key = 'sk_live_abc'

      expect(configuration.headers).to include(
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      )
    end

    it 'raises ConfigurationError when the api_key is missing' do
      configuration.api_key = nil

      expect { configuration.headers }.to raise_error(
        SyntageSdk::ConfigurationError, /Missing Syntage API key/
      )
    end

    it 'raises ConfigurationError when the api_key is blank' do
      configuration.api_key = '   '

      expect { configuration.headers }.to raise_error(SyntageSdk::ConfigurationError)
    end
  end
end
