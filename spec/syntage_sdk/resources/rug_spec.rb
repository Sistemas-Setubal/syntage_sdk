require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Rug do
  subject(:rug) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#guarantees' do
    it 'gets the entity-scoped rug/garantias path' do
      rug.guarantees

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/rug/garantias', anything)
    end

    it 'requests the JSON-LD representation' do
      rug.guarantees

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      rug.guarantees

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps items_per_page to the camelCase param' do
      rug.guarantees items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'forwards the offset page' do
      rug.guarantees page: 2

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 2)))
    end

    it 'returns the client response' do
      expect(rug.guarantees).to be(response)
    end
  end

  describe '#guarantee' do
    it 'gets the rug/garantias/{id} path' do
      rug.guarantee 'abc-123'

      expect(client).to have_received(:get)
        .with('datasources/rug/garantias/abc-123', anything)
    end

    it 'requests the JSON-LD representation' do
      rug.guarantee 'abc-123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(rug.guarantee('abc-123')).to be(response)
    end
  end

  describe '#operations' do
    it 'gets the entity-scoped rug/operaciones path' do
      rug.operations

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/rug/operaciones', anything)
    end

    it 'requests the JSON-LD representation' do
      rug.operations

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      rug.operations

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps items_per_page to the camelCase param' do
      rug.operations items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'returns the client response' do
      expect(rug.operations).to be(response)
    end
  end
end
