require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Files do
  subject(:files) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#retrieve' do
    it 'gets the file path with the id' do
      files.retrieve 'file_1'

      expect(client).to have_received(:get).with('files/file_1', anything)
    end

    it 'requests the JSON-LD representation' do
      files.retrieve 'file_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(files.retrieve('file_1')).to be(response)
    end
  end

  describe '#download' do
    it 'gets the file download path with the id' do
      files.download 'file_1'

      expect(client).to have_received(:get).with('files/file_1/download', anything)
    end

    it 'accepts any content type so the body is not parsed as JSON' do
      files.download 'file_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => '*/*')))
    end

    it 'returns the client response' do
      expect(files.download('file_1')).to be(response)
    end
  end
end
