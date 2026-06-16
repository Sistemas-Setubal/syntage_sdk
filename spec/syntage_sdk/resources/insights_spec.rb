require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights do
  subject(:insights) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#metrics' do
    it 'returns a metrics resource' do
      expect(insights.metrics).to be_a(SyntageSdk::Resources::Insights::Metrics)
    end
  end

  describe '#financial_ratios' do
    it 'gets the entity-scoped financial-ratios path' do
      insights.financial_ratios

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/financial-ratios', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.financial_ratios

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.financial_ratios from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'maps to to the options[to] query param' do
      insights.financial_ratios to: '2024-12-31T23:59:59Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[to]' => '2024-12-31T23:59:59Z')))
    end

    it 'omits date filters that are not given' do
      insights.financial_ratios from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.financial_ratios).to be(response)
    end
  end

  describe '#trial_balance' do
    it 'gets the entity-scoped trial-balance path' do
      insights.trial_balance

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/trial-balance', anything)
    end

    it 'maps periodicity to the options[periodicity] query param' do
      insights.trial_balance periodicity: 'monthly'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[periodicity]' => 'monthly')))
    end

    it 'maps from to the options[from] query param' do
      insights.trial_balance from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits filters that are not given' do
      insights.trial_balance periodicity: 'monthly'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[from]')))
    end

    it 'returns the client response' do
      expect(insights.trial_balance).to be(response)
    end
  end
end
