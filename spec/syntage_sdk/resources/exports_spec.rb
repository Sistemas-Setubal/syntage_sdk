require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Exports do
  subject(:exports) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the exports path' do
      exports.list

      expect(client).to have_received(:get).with('exports', anything)
    end

    it 'requests the JSON-LD representation' do
      exports.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      exports.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'sends the status filter' do
      exports.list status: 'finished'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'finished')))
    end

    it 'sends the format filter' do
      exports.list format: 'pdf'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('format' => 'pdf')))
    end

    it 'sends the id filter' do
      exports.list id: 'exp_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id' => 'exp_1')))
    end

    it 'combines the status and format filters' do
      exports.list status: 'finished', format: 'pdf'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: { 'status' => 'finished', 'format' => 'pdf' }))
    end

    it 'sends itemsPerPage when given' do
      exports.list items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'sends page when given' do
      exports.list page: 2

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 2)))
    end

    it 'ignores unsupported filters' do
      exports.list uri: '/entities'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(exports.list).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the exports path' do
      exports.create format: 'csv', uri: '/entities'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(path: 'exports'))
    end

    it 'includes the format' do
      exports.create format: 'csv', uri: '/entities'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(format: 'csv')))
    end

    it 'includes the uri' do
      exports.create format: 'csv', uri: '/entities'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(uri: '/entities')))
    end

    it 'raises when format is missing' do
      expect { exports.create uri: '/entities' }.to raise_error(ArgumentError)
    end

    it 'raises when uri is missing' do
      expect { exports.create format: 'csv' }.to raise_error(ArgumentError)
    end

    it 'maps file_types to the camelCase fileTypes field' do
      exports.create format: 'csv', uri: '/entities', file_types: ['invoice.cfdi.xml']

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(fileTypes: ['invoice.cfdi.xml'])))
    end

    it 'omits fileTypes when not given' do
      exports.create format: 'csv', uri: '/entities'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:fileTypes)))
    end

    it 'returns the client response' do
      expect(exports.create(format: 'csv', uri: '/entities')).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the export path with the id' do
      exports.retrieve 'exp_1'

      expect(client).to have_received(:get).with('exports/exp_1', anything)
    end

    it 'requests the JSON-LD representation' do
      exports.retrieve 'exp_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(exports.retrieve('exp_1')).to be(response)
    end
  end
end
