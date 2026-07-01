require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::EntityTags do
  subject(:entity_tags) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, patch: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-tags path' do
      entity_tags.list

      expect(client).to have_received(:get).with('entity-tags', anything)
    end

    it 'requests the JSON-LD representation' do
      entity_tags.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      entity_tags.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      entity_tags.list id_lt: 'etag_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'etag_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      entity_tags.list id_gt: 'etag_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'etag_100')))
    end

    it 'returns the client response' do
      expect(entity_tags.list).to be(response)
    end
  end

  describe '#list_for_entity' do
    it 'gets the entity-scoped tags path' do
      entity_tags.list_for_entity entity_id: 'ent_123'

      expect(client).to have_received(:get).with('entities/ent_123/tags', anything)
    end

    it 'requests the JSON-LD representation' do
      entity_tags.list_for_entity entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'requires the entity_id keyword' do
      expect { entity_tags.list_for_entity }.to raise_error(ArgumentError)
    end

    it 'maps id_lt to the bracketed cursor param' do
      entity_tags.list_for_entity entity_id: 'ent_123', id_lt: 'etag_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'etag_500')))
    end

    it 'maps items_per_page to the camelCase param' do
      entity_tags.list_for_entity entity_id: 'ent_123', items_per_page: 20

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 20)))
    end

    it 'returns the client response' do
      expect(entity_tags.list_for_entity(entity_id: 'ent_123')).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the entity-tags path with the given id' do
      entity_tags.retrieve 'etag_123'

      expect(client).to have_received(:get).with('entity-tags/etag_123', anything)
    end

    it 'requests the JSON-LD representation' do
      entity_tags.retrieve 'etag_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(entity_tags.retrieve('etag_123')).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the entity-tags path' do
      entity_tags.create name: 'vip'

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'entity-tags'))
    end

    it 'sends name in the body' do
      entity_tags.create name: 'vip'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(name: 'vip')))
    end

    it 'requires the name keyword' do
      expect { entity_tags.create }.to raise_error(ArgumentError)
    end

    it 'returns the client response' do
      expect(entity_tags.create(name: 'vip')).to be(response)
    end
  end

  describe '#update' do
    it 'patches the entity-tags path with the given id' do
      entity_tags.update 'etag_123', name: 'premium'

      expect(client).to have_received(:patch).with(an_object_having_attributes(path: 'entity-tags/etag_123'))
    end

    it 'sends name in the body' do
      entity_tags.update 'etag_123', name: 'premium'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_including(name: 'premium')))
    end

    it 'returns the client response' do
      expect(entity_tags.update('etag_123', name: 'premium')).to be(response)
    end
  end

  describe '#destroy' do
    it 'deletes the entity-tags path with the given id' do
      entity_tags.destroy 'etag_123'

      expect(client).to have_received(:delete).with('entity-tags/etag_123')
    end

    it 'returns the client response' do
      expect(entity_tags.destroy('etag_123')).to be(response)
    end
  end
end
