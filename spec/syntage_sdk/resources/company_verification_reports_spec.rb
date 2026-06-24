require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::CompanyVerificationReports do
  subject(:reports) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped reports path' do
      reports.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/mx/company-verification/reports', anything)
    end

    it 'requests the JSON-LD representation' do
      reports.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      reports.list entity_id: 'ent_123'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      reports.list entity_id: 'ent_123', id_lt: '500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => '500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      reports.list entity_id: 'ent_123', id_gt: '100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => '100')))
    end

    it 'maps order created_at to the bracketed param' do
      reports.list entity_id: 'ent_123', order: { created_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'desc')))
    end

    it 'maps order updated_at to the bracketed param' do
      reports.list entity_id: 'ent_123', order: { updated_at: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[updatedAt]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      reports.list entity_id: 'ent_123', items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'enables cursor pagination when cursor: true' do
      reports.list entity_id: 'ent_123', cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      reports.list entity_id: 'ent_123', unknown: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(reports.list(entity_id: 'ent_123')).to be(response)
    end
  end

  describe '#list_all' do
    it 'gets the global reports path' do
      reports.list_all

      expect(client).to have_received(:get)
        .with('datasources/mx/company-verification/reports', anything)
    end

    it 'requests the JSON-LD representation' do
      reports.list_all

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      reports.list_all id_lt: '500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => '500')))
    end

    it 'returns the client response' do
      expect(reports.list_all).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the global reports path with id' do
      reports.retrieve 'cvr_123'

      expect(client).to have_received(:get)
        .with('datasources/mx/company-verification/reports/cvr_123', anything)
    end

    it 'requests the JSON-LD representation' do
      reports.retrieve 'cvr_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(reports.retrieve('cvr_123')).to be(response)
    end
  end
end
