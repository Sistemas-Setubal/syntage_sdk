require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Schedulers do
  subject(:schedulers) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, put: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the schedulers path' do
      schedulers.list

      expect(client).to have_received(:get).with('schedulers', anything)
    end

    it 'requests the JSON-LD representation' do
      schedulers.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      schedulers.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      schedulers.list id_lt: 'sch_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'sch_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      schedulers.list id_gt: 'sch_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'sch_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      schedulers.list items_per_page: 20

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 20)))
    end

    it 'returns the client response' do
      expect(schedulers.list).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the schedulers path' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(path: 'schedulers'))
    end

    it 'defaults the type to recurring' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(type: 'recurring')))
    end

    it 'allows overriding the type' do
      schedulers.create type: 'custom'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(type: 'custom')))
    end

    it 'includes the name when given' do
      schedulers.create name: 'Daily'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(name: 'Daily')))
    end

    it 'omits the name when not given' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:name)))
    end

    it 'maps is_enabled to the camelCase isEnabled field' do
      schedulers.create is_enabled: false

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(isEnabled: false)))
    end

    it 'omits isEnabled when not given' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:isEnabled)))
    end

    it 'includes the tags when given' do
      schedulers.create tags: ['/tags/1']

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(tags: ['/tags/1'])))
    end

    it 'returns the client response' do
      expect(schedulers.create).to be(response)
    end
  end

  describe '#update' do
    it 'puts to the scheduler path with the id' do
      schedulers.update 'sch_1', name: 'Daily'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(path: 'schedulers/sch_1'))
    end

    it 'maps is_enabled to the camelCase isEnabled field' do
      schedulers.update 'sch_1', is_enabled: false

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(isEnabled: false)))
    end

    it 'includes the tags when given' do
      schedulers.update 'sch_1', tags: ['/tags/1']

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(tags: ['/tags/1'])))
    end

    it 'omits fields that are not given' do
      schedulers.update 'sch_1', name: 'Daily'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_excluding(:isEnabled)))
    end

    it 'returns the client response' do
      expect(schedulers.update('sch_1', name: 'Daily')).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the scheduler path with the id' do
      schedulers.retrieve 'sch_1'

      expect(client).to have_received(:get).with('schedulers/sch_1', anything)
    end

    it 'requests the JSON-LD representation' do
      schedulers.retrieve 'sch_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(schedulers.retrieve('sch_1')).to be(response)
    end
  end

  describe '#delete' do
    it 'deletes the scheduler path with the id' do
      schedulers.delete 'sch_1'

      expect(client).to have_received(:delete).with('schedulers/sch_1')
    end

    it 'returns the client response' do
      expect(schedulers.delete('sch_1')).to be(response)
    end
  end
end
