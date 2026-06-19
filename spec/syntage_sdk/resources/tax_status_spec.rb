require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxStatus do
  subject(:tax_status) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

  describe '#list' do
    it 'gets the entity tax-status path' do
      tax_status.list entity_id: entity_id

      expect(client).to have_received(:get).with("entities/#{entity_id}/tax-status", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_status.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      tax_status.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'does not send entity_id as a query param' do
      tax_status.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      tax_status.list entity_id: entity_id, id_lt: 'ts_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'ts_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      tax_status.list entity_id: entity_id, id_gt: 'ts_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'ts_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      tax_status.list entity_id: entity_id, items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'requests cursor pagination style when asked' do
      tax_status.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      tax_status.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(tax_status.list(entity_id: entity_id)).to be(response)
    end
  end
end
