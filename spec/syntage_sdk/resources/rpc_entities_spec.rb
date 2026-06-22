require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::RpcEntities do
  subject(:rpc_entities) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped rpc/entidades path' do
      rpc_entities.list

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/rpc/entidades', anything)
    end

    it 'requests the JSON-LD representation' do
      rpc_entities.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      rpc_entities.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps items_per_page to the camelCase param' do
      rpc_entities.list items_per_page: 10

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 10)))
    end

    it 'enables cursor pagination when cursor: true' do
      rpc_entities.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'returns the client response' do
      expect(rpc_entities.list).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the global rpc/entidades path with id' do
      rpc_entities.retrieve 'rpc_123'

      expect(client).to have_received(:get)
        .with('datasources/rpc/entidades/rpc_123', anything)
    end

    it 'requests the JSON-LD representation' do
      rpc_entities.retrieve 'rpc_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(rpc_entities.retrieve('rpc_123')).to be(response)
    end
  end
end
