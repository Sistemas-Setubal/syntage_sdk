require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Bil do
  subject(:bil) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped bil reports path' do
      bil.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/bil/reports', anything)
    end

    it 'requests the JSON-LD representation' do
      bil.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      bil.list entity_id: 'ent_123'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      bil.list entity_id: 'ent_123', id_lt: '500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => '500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      bil.list entity_id: 'ent_123', id_gt: '100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => '100')))
    end

    it 'maps order created_at to the bracketed param' do
      bil.list entity_id: 'ent_123', order: { created_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'desc')))
    end

    it 'maps items_per_page to the camelCase param' do
      bil.list entity_id: 'ent_123', items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'rejects items_per_page above 100 before calling the API' do
      expect { bil.list entity_id: 'ent_123', items_per_page: 101 }
        .to raise_error ArgumentError, /between 1 and 100/
      expect(client).not_to have_received(:get)
    end

    it 'rejects items_per_page below 1' do
      expect { bil.list entity_id: 'ent_123', items_per_page: 0 }
        .to raise_error ArgumentError, /between 1 and 100/
    end

    it 'rejects a non-integer items_per_page' do
      expect { bil.list entity_id: 'ent_123', items_per_page: '50' }
        .to raise_error ArgumentError, /got "50"/
    end

    it 'accepts items_per_page of 1' do
      bil.list entity_id: 'ent_123', items_per_page: 1

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 1)))
    end

    it 'enables cursor pagination when cursor: true' do
      bil.list entity_id: 'ent_123', cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'omits the cursor header by default' do
      bil.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_excluding('X-Pagination-Style')))
    end

    it 'ignores unknown filters' do
      bil.list entity_id: 'ent_123', unknown: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'requires entity_id' do
      expect { bil.list }.to raise_error ArgumentError, /entity_id/
    end

    it 'returns the client response' do
      expect(bil.list(entity_id: 'ent_123')).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the bil report path with id' do
      bil.retrieve 'bil_123'

      expect(client).to have_received(:get)
        .with('datasources/bil/reports/bil_123', anything)
    end

    it 'requests the JSON-LD representation' do
      bil.retrieve 'bil_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(bil.retrieve('bil_123')).to be(response)
    end
  end
end
