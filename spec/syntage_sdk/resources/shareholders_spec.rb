require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Shareholders do
  subject(:shareholders) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, patch: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped shareholders path' do
      shareholders.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with('entities/ent_123/shareholders', anything)
    end

    it 'requests the JSON-LD representation' do
      shareholders.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      shareholders.list entity_id: 'ent_123'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the type filter' do
      shareholders.list entity_id: 'ent_123', type: 'physical'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'physical')))
    end

    it 'forwards the name filter' do
      shareholders.list entity_id: 'ent_123', name: 'JUAN PEREZ'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('name' => 'JUAN PEREZ')))
    end

    it 'forwards the rfc filter' do
      shareholders.list entity_id: 'ent_123', rfc: 'PEGJ850101'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('rfc' => 'PEGJ850101')))
    end

    it 'maps order name to the bracketed param' do
      shareholders.list entity_id: 'ent_123', order: { name: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[name]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      shareholders.list entity_id: 'ent_123', items_per_page: 20

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 20)))
    end

    it 'enables cursor pagination when cursor: true' do
      shareholders.list entity_id: 'ent_123', cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      shareholders.list entity_id: 'ent_123', unknown: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(shareholders.list(entity_id: 'ent_123')).to be(response)
    end
  end

  describe '#list_all' do
    it 'gets the global shareholders path' do
      shareholders.list_all

      expect(client).to have_received(:get).with('shareholders', anything)
    end

    it 'requests the JSON-LD representation' do
      shareholders.list_all

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'forwards the type filter' do
      shareholders.list_all type: 'legal'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'legal')))
    end

    it 'returns the client response' do
      expect(shareholders.list_all).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the global shareholders path with id' do
      shareholders.retrieve 'sh_123'

      expect(client).to have_received(:get)
        .with('shareholders/sh_123', anything)
    end

    it 'requests the JSON-LD representation' do
      shareholders.retrieve 'sh_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(shareholders.retrieve('sh_123')).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the entity-scoped shareholders path' do
      shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50

      expect(client).to have_received(:post)
        .with('entities/ent_123/shareholders', anything)
    end

    it 'sends the required fields in camelCase' do
      shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(relationType: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50))
    end

    it 'includes rfc when given' do
      shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50, rfc: 'PEGJ850101HM2'

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(rfc: 'PEGJ850101HM2'))
    end

    it 'omits rfc when not given' do
      shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50

      expect(client).to have_received(:post)
        .with(anything, body: ->(body) { !body.key?(:rfc) })
    end

    it 'raises ArgumentError when relation_type is missing' do
      expect { shareholders.create entity_id: 'ent_123', name: 'JUAN PEREZ', shares: 1500.50 }
        .to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when name is missing' do
      expect { shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', shares: 1500.50 }
        .to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when shares is missing' do
      expect { shareholders.create entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ' }
        .to raise_error(ArgumentError)
    end

    it 'returns the client response' do
      expect(
        shareholders.create(entity_id: 'ent_123', relation_type: 'shareholders', name: 'JUAN PEREZ', shares: 1500.50)
      ).to be(response)
    end
  end

  describe '#update' do
    it 'patches the global shareholders path' do
      shareholders.update 'sh_123', name: 'NUEVO NOMBRE'

      expect(client).to have_received(:patch).with('shareholders/sh_123', anything)
    end

    it 'sends the name when given' do
      shareholders.update 'sh_123', name: 'NUEVO NOMBRE'

      expect(client).to have_received(:patch)
        .with(anything, body: hash_including(name: 'NUEVO NOMBRE'))
    end

    it 'sends the rfc when given' do
      shareholders.update 'sh_123', rfc: 'PEGJ850101HM2'

      expect(client).to have_received(:patch)
        .with(anything, body: hash_including(rfc: 'PEGJ850101HM2'))
    end

    it 'omits fields not given' do
      shareholders.update 'sh_123', name: 'NUEVO NOMBRE'

      expect(client).to have_received(:patch)
        .with(anything, body: ->(body) { !body.key?(:rfc) })
    end

    it 'ignores unknown fields' do
      shareholders.update 'sh_123', unknown: 'value'

      expect(client).to have_received(:patch).with(anything, body: {})
    end

    it 'returns the client response' do
      expect(shareholders.update('sh_123', name: 'NUEVO NOMBRE')).to be(response)
    end
  end

  describe '#delete' do
    it 'deletes the global shareholders path' do
      shareholders.delete 'sh_123'

      expect(client).to have_received(:delete).with('shareholders/sh_123')
    end

    it 'returns the client response' do
      expect(shareholders.delete('sh_123')).to be(response)
    end
  end
end
