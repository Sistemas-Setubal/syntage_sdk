require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::BackgroundChecks do
  subject(:background_checks) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped background-checks path' do
      background_checks.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with('entities/ent_123/background-checks', anything)
    end

    it 'requests the JSON-LD representation' do
      background_checks.list entity_id: 'ent_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      background_checks.list entity_id: 'ent_123'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the status filter' do
      background_checks.list entity_id: 'ent_123', status: 'completed'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'completed')))
    end

    it 'forwards the country filter' do
      background_checks.list entity_id: 'ent_123', country: 'MX'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('country' => 'MX')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      background_checks.list entity_id: 'ent_123', id_lt: '500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => '500')))
    end

    it 'maps order score to the bracketed param' do
      background_checks.list entity_id: 'ent_123', order: { score: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[score]' => 'desc')))
    end

    it 'maps items_per_page to the camelCase param' do
      background_checks.list entity_id: 'ent_123', items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'enables cursor pagination when cursor: true' do
      background_checks.list entity_id: 'ent_123', cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      background_checks.list entity_id: 'ent_123', unknown: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(background_checks.list(entity_id: 'ent_123')).to be(response)
    end
  end

  describe '#list_all' do
    it 'gets the global background-checks path' do
      background_checks.list_all

      expect(client).to have_received(:get).with('background-checks', anything)
    end

    it 'requests the JSON-LD representation' do
      background_checks.list_all

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'forwards the status filter' do
      background_checks.list_all status: 'pending'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'pending')))
    end

    it 'returns the client response' do
      expect(background_checks.list_all).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the global background-checks path with id' do
      background_checks.retrieve 'bgc_123'

      expect(client).to have_received(:get)
        .with('background-checks/bgc_123', anything)
    end

    it 'requests the JSON-LD representation' do
      background_checks.retrieve 'bgc_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(background_checks.retrieve('bgc_123')).to be(response)
    end
  end

  describe '#pdf' do
    it 'gets the background-check pdf path' do
      background_checks.pdf 'bgc_123'

      expect(client).to have_received(:get)
        .with('background-checks/bgc_123/pdf', anything)
    end

    it 'requests the JSON-LD representation' do
      background_checks.pdf 'bgc_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(background_checks.pdf('bgc_123')).to be(response)
    end
  end

  describe '#records' do
    it 'gets the background-check records path' do
      background_checks.records 'bgc_123'

      expect(client).to have_received(:get)
        .with('background-checks/bgc_123/records', anything)
    end

    it 'requests the JSON-LD representation' do
      background_checks.records 'bgc_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'forwards the category filter' do
      background_checks.records 'bgc_123', category: 'criminal_record'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('category' => 'criminal_record')))
    end

    it 'maps order created_at to the bracketed param' do
      background_checks.records 'bgc_123', order: { created_at: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'asc')))
    end

    it 'ignores unknown filters' do
      background_checks.records 'bgc_123', unknown: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(background_checks.records('bgc_123')).to be(response)
    end
  end
end
