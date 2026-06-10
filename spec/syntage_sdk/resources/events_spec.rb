require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Events do
  subject(:events) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the events path' do
      events.list

      expect(client).to have_received(:get).with('events', anything)
    end

    it 'requests the JSON-LD representation' do
      events.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      events.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the type filter' do
      events.list type: 'credential.updated'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'credential.updated')))
    end

    it 'maps taxpayer_id to the dotted taxpayer.id param' do
      events.list taxpayer_id: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.id' => 'XAXX010101000')))
    end

    it 'forwards the source IRI' do
      events.list source: '/extractions/123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('source' => '/extractions/123')))
    end

    it 'forwards the resource IRI' do
      events.list resource: '/credentials/123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('resource' => '/credentials/123')))
    end

    it 'maps created_at filters to bracketed params' do
      events.list created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'omits created_at filters that are not given' do
      events.list created_at: { before: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('createdAt[after]')))
    end

    it 'maps order to the bracketed createdAt param' do
      events.list order: 'desc'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'desc')))
    end

    it 'maps items_per_page to the camelCase param' do
      events.list items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'forwards the offset page' do
      events.list page: 3

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 3)))
    end

    it 'forwards the cursor_next token' do
      events.list cursor_next: 'abc'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('cursor_next' => 'abc')))
    end

    it 'requests cursor pagination style when asked' do
      events.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'omits the pagination style header by default' do
      events.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_excluding('X-Pagination-Style')))
    end

    it 'ignores unknown filters' do
      events.list bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(events.list).to be(response)
    end
  end
end
