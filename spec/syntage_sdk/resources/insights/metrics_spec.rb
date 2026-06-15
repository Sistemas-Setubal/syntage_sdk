require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights::Metrics do
  subject(:metrics) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#balance_sheet' do
    it 'gets the entity-scoped balance-sheet metrics path' do
      metrics.balance_sheet

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/metrics/balance-sheet', anything)
    end

    it 'sends an empty query when no filters are given' do
      metrics.balance_sheet

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'omits the insight format header by default' do
      metrics.balance_sheet

      expect(client).to have_received(:get).with(anything, hash_including(headers: nil))
    end

    it 'forwards the format as the X-Insight-Format header' do
      metrics.balance_sheet format: 2022

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'X-Insight-Format' => '2022' }))
    end

    it 'maps from to the options[from] query param' do
      metrics.balance_sheet from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'maps to to the options[to] query param' do
      metrics.balance_sheet to: '2024-12-31T23:59:59Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[to]' => '2024-12-31T23:59:59Z')))
    end

    it 'omits date filters that are not given' do
      metrics.balance_sheet from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(metrics.balance_sheet).to be(response)
    end
  end
end
