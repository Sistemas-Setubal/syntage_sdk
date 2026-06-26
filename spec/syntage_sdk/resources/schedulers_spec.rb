require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Schedulers do
  subject(:schedulers) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#create' do
    it 'posts to the schedulers path' do
      schedulers.create

      expect(client).to have_received(:post).with('schedulers', anything)
    end

    it 'defaults the type to recurring' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(type: 'recurring'))
    end

    it 'allows overriding the type' do
      schedulers.create type: 'custom'

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(type: 'custom'))
    end

    it 'includes the name when given' do
      schedulers.create name: 'Daily'

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(name: 'Daily'))
    end

    it 'omits the name when not given' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(anything, body: hash_excluding(:name))
    end

    it 'maps is_enabled to the camelCase isEnabled field' do
      schedulers.create is_enabled: false

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(isEnabled: false))
    end

    it 'omits isEnabled when not given' do
      schedulers.create

      expect(client).to have_received(:post)
        .with(anything, body: hash_excluding(:isEnabled))
    end

    it 'includes the tags when given' do
      schedulers.create tags: ['/tags/1']

      expect(client).to have_received(:post)
        .with(anything, body: hash_including(tags: ['/tags/1']))
    end

    it 'returns the client response' do
      expect(schedulers.create).to be(response)
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
