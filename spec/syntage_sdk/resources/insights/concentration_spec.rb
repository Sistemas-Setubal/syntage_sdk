require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights::Concentration do
  subject(:concentration) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#invoicing' do
    it 'gets the invoicing-concentration path' do
      concentration.invoicing type: 'issued'

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/invoicing-concentration', anything)
    end

    it 'sends type in the query' do
      concentration.invoicing type: 'issued'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[type]' => 'issued')))
    end

    it 'raises ArgumentError when type is missing' do
      expect { concentration.invoicing }.to raise_error(ArgumentError)
    end

    it 'maps from to the options[from] query param' do
      concentration.invoicing type: 'received', from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      concentration.invoicing type: 'issued', from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(concentration.invoicing(type: 'issued')).to be(response)
    end
  end

  describe '#customer' do
    it 'gets the customer-concentration path' do
      concentration.customer

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/customer-concentration', anything)
    end

    it 'sends an empty query when no filters are given' do
      concentration.customer

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      concentration.customer from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      concentration.customer from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(concentration.customer).to be(response)
    end
  end

  describe '#supplier' do
    it 'gets the supplier-concentration path' do
      concentration.supplier

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/supplier-concentration', anything)
    end

    it 'sends an empty query when no filters are given' do
      concentration.supplier

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      concentration.supplier from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      concentration.supplier from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(concentration.supplier).to be(response)
    end
  end
end
