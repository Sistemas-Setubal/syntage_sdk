require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights::Metrics do
  subject(:metrics) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  shared_examples 'a financial statement metric' do |method, segment|
    it 'gets the entity-scoped metric path' do
      metrics.public_send method

      expect(client).to have_received(:get)
        .with("entities/ent_123/insights/metrics/#{segment}", anything)
    end

    it 'sends an empty query when no filters are given' do
      metrics.public_send method

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'omits the insight format header by default' do
      metrics.public_send method

      expect(client).to have_received(:get).with(anything, hash_including(headers: nil))
    end

    it 'forwards the format as the X-Insight-Format header' do
      metrics.public_send method, format: 2022

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'X-Insight-Format' => '2022' }))
    end

    it 'maps from to the options[from] query param' do
      metrics.public_send method, from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'maps to to the options[to] query param' do
      metrics.public_send method, to: '2024-12-31T23:59:59Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[to]' => '2024-12-31T23:59:59Z')))
    end

    it 'omits date filters that are not given' do
      metrics.public_send method, from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(metrics.public_send(method)).to be(response)
    end
  end

  describe '#balance_sheet' do
    it_behaves_like 'a financial statement metric', :balance_sheet, 'balance-sheet'
  end

  describe '#income_statement' do
    it_behaves_like 'a financial statement metric', :income_statement, 'income-statement'
  end

  describe '#scores' do
    it 'gets the entity-scoped scores metric path' do
      metrics.scores

      expect(client).to have_received(:get).with('entities/ent_123/insights/metrics/scores')
    end

    it 'returns the client response' do
      expect(metrics.scores).to be(response)
    end
  end
end
