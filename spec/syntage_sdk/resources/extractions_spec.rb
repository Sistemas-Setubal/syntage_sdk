require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Extractions do
  subject(:extractions) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the extractions path' do
      extractions.list

      expect(client).to have_received(:get).with('extractions', anything)
    end

    it 'requests the JSON-LD representation' do
      extractions.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      extractions.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the extractor filter' do
      extractions.list extractor: 'tax_status'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('extractor' => 'tax_status')))
    end

    it 'forwards the status filter' do
      extractions.list status: 'finished'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'finished')))
    end

    it 'forwards the datasource filter' do
      extractions.list datasource: 'sat'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('datasource' => 'sat')))
    end

    it 'maps taxpayer_id to the dotted taxpayer.id param' do
      extractions.list taxpayer_id: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.id' => 'XAXX010101000')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      extractions.list id_lt: 'ext_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'ext_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      extractions.list id_gt: 'ext_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'ext_100')))
    end

    it 'maps started_at filters to bracketed params' do
      extractions.list started_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('startedAt[after]' => '2026-01-01')))
    end

    it 'maps finished_at filters to bracketed params' do
      extractions.list finished_at: { before: '2026-06-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('finishedAt[before]' => '2026-06-01')))
    end

    it 'maps order to the started_at bracketed param' do
      extractions.list order: { started_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[startedAt]' => 'desc')))
    end

    it 'maps items_per_page to the camelCase param' do
      extractions.list items_per_page: 20

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 20)))
    end

    it 'returns the client response' do
      expect(extractions.list).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the extraction path with the id' do
      extractions.retrieve 'ext_1'

      expect(client).to have_received(:get).with('extractions/ext_1', anything)
    end

    it 'requests the JSON-LD representation' do
      extractions.retrieve 'ext_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(extractions.retrieve('ext_1')).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the extractions path' do
      extractions.create entity: '/entities/1', extractor: 'tax_status'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(path: 'extractions'))
    end

    it 'includes the entity and extractor' do
      extractions.create entity: '/entities/1', extractor: 'tax_status'

      expect(client).to have_received(:post).with(
        an_object_having_attributes(body: hash_including(entity: '/entities/1', extractor: 'tax_status'))
      )
    end

    it 'includes options when given' do
      extractions.create entity: '/entities/1', extractor: 'annual_tax_return',
options: { period: { from: '2026-01-01' } }

      expect(client).to have_received(:post).with(
        an_object_having_attributes(body: hash_including(options: { period: { from: '2026-01-01' } }))
      )
    end

    it 'omits options when not given' do
      extractions.create entity: '/entities/1', extractor: 'tax_status'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:options)))
    end

    it 'raises without an entity' do
      expect { extractions.create(extractor: 'tax_status') }.to raise_error ArgumentError
    end

    it 'raises without an extractor' do
      expect { extractions.create(entity: '/entities/1') }.to raise_error ArgumentError
    end

    it 'returns the client response' do
      expect(extractions.create(entity: '/entities/1', extractor: 'tax_status')).to be(response)
    end
  end

  describe '#stop' do
    it 'deletes the extraction stop path with the id' do
      extractions.stop 'ext_1'

      expect(client).to have_received(:delete).with('extractions/ext_1/stop')
    end

    it 'returns the client response' do
      expect(extractions.stop('ext_1')).to be(response)
    end
  end
end
