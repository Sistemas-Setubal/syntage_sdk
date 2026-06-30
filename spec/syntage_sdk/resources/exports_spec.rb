require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Exports do
  subject(:exports) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response }
  let(:response) { instance_double SyntageSdk::Response }

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
