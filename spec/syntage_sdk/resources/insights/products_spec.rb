require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights::Products do
  subject(:products) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#sold' do
    it 'gets the products-and-services-sold path' do
      products.sold

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/products-and-services-sold', anything)
    end

    it 'sends an empty query when no filters are given' do
      products.sold

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      products.sold from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      products.sold from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(products.sold).to be(response)
    end
  end

  describe '#bought' do
    it 'gets the products-and-services-bought path' do
      products.bought

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/products-and-services-bought', anything)
    end

    it 'sends an empty query when no filters are given' do
      products.bought

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      products.bought from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      products.bought from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(products.bought).to be(response)
    end
  end
end
