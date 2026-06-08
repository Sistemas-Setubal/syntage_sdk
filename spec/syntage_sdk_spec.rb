# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk do
  after { described_class.reset_configuration! }

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(described_class.configuration).to be_a(SyntageSdk::Configuration)
    end

    it 'memoizes the same instance across calls' do
      expect(described_class.configuration).to equal(described_class.configuration)
    end

    it 'is aliased as .config' do
      expect(described_class.config).to equal(described_class.configuration)
    end
  end

  describe '.configure' do
    it 'yields the configuration so the client can set it up centrally' do
      described_class.configure { |config| config.api_key = 'sk_test_123' }

      expect(described_class.config.api_key).to eq('sk_test_123')
    end

    it 'returns the configuration' do
      result = described_class.configure { |config| config.api_key = 'sk_test_123' }

      expect(result).to equal(described_class.configuration)
    end
  end

  describe '.reset_configuration!' do
    it 'replaces the configuration with a fresh instance' do
      original = described_class.configuration
      described_class.reset_configuration!

      expect(described_class.configuration).not_to equal(original)
    end
  end
end
