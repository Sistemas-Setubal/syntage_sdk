require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Tags do
  subject(:tags) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, patch: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the tags path' do
      tags.list

      expect(client).to have_received(:get).with('tags', anything)
    end

    it 'requests the JSON-LD representation' do
      tags.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      tags.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(tags.list).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the tags path' do
      tags.create name: 'urgent', resource_type: 'invoice'

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'tags'))
    end

    it 'sends name in the body' do
      tags.create name: 'urgent', resource_type: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(name: 'urgent')))
    end

    it 'sends resourceType in the body' do
      tags.create name: 'urgent', resource_type: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(resourceType: 'invoice')))
    end

    it 'sends resourceId when provided' do
      tags.create name: 'urgent', resource_type: 'invoice', resource_id: 'inv_123'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(resourceId: 'inv_123')))
    end

    it 'omits resourceId when not provided' do
      tags.create name: 'urgent', resource_type: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: satisfy { |b| !b.key?(:resourceId) }))
    end

    it 'returns the client response' do
      expect(tags.create(name: 'urgent', resource_type: 'invoice')).to be(response)
    end
  end

  describe '#update' do
    it 'patches the tags path with the given id' do
      tags.update 'tag_123', name: 'reviewed'

      expect(client).to have_received(:patch).with(an_object_having_attributes(path: 'tags/tag_123'))
    end

    it 'sends name in the body' do
      tags.update 'tag_123', name: 'reviewed'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_including(name: 'reviewed')))
    end

    it 'returns the client response' do
      expect(tags.update('tag_123', name: 'reviewed')).to be(response)
    end
  end

  describe '#destroy' do
    it 'deletes the tags path with the given id' do
      tags.destroy 'tag_123'

      expect(client).to have_received(:delete).with('tags/tag_123')
    end

    it 'returns the client response' do
      expect(tags.destroy('tag_123')).to be(response)
    end
  end
end
