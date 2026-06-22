require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::ElectronicAccounting do
  subject(:electronic_accounting) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

  describe '#list' do
    it 'gets the entity electronic-accounting-records path' do
      electronic_accounting.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/electronic-accounting-records", anything)
    end

    it 'requests the JSON-LD representation' do
      electronic_accounting.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      electronic_accounting.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'does not send entity_id as a query param' do
      electronic_accounting.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps year to the query' do
      electronic_accounting.list entity_id: entity_id, year: 2026

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('year' => 2026)))
    end

    it 'maps month to the query' do
      electronic_accounting.list entity_id: entity_id, month: 6

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('month' => 6)))
    end

    it 'maps type to the query' do
      electronic_accounting.list entity_id: entity_id, type: 'N'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'N')))
    end

    it 'maps reason to the query' do
      electronic_accounting.list entity_id: entity_id, reason: 'AF'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('reason' => 'AF')))
    end

    it 'maps file_type to the camelCase param' do
      electronic_accounting.list entity_id: entity_id, file_type: 'CT'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('fileType' => 'CT')))
    end

    it 'maps filename to the query' do
      electronic_accounting.list entity_id: entity_id, filename: 'AAA010101AAA'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('filename' => 'AAA010101AAA')))
    end

    it 'maps code to the query' do
      electronic_accounting.list entity_id: entity_id, code: '01'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('code' => '01')))
    end

    it 'maps status to the query' do
      electronic_accounting.list entity_id: entity_id, status: 'accepted'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'accepted')))
    end

    it 'maps received_at date filter to the bracketed camelCase param' do
      electronic_accounting.list entity_id: entity_id, received_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('receivedAt[after]' => '2026-01-01')))
    end

    it 'maps order received_at to the bracketed camelCase param' do
      electronic_accounting.list entity_id: entity_id, order: { received_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[receivedAt]' => 'desc')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      electronic_accounting.list entity_id: entity_id, id_lt: 'ear_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'ear_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      electronic_accounting.list entity_id: entity_id, id_gt: 'ear_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'ear_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      electronic_accounting.list entity_id: entity_id, items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'requests cursor pagination style when asked' do
      electronic_accounting.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      electronic_accounting.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(electronic_accounting.list(entity_id: entity_id)).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the singular electronic-accounting-records path' do
      electronic_accounting.retrieve id

      expect(client).to have_received(:get).with("electronic-accounting-records/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      electronic_accounting.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      electronic_accounting.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(electronic_accounting.retrieve(id)).to be(response)
    end
  end
end
