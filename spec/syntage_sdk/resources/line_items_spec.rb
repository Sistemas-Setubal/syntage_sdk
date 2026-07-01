require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::LineItems do
  subject(:line_items) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:invoice_id) { 'a1fd895b-5dcb-4cb4-89bc-3467f460c75b' }

  describe '#list' do
    it 'gets the invoice line items path' do
      line_items.list invoice_id: invoice_id

      expect(client).to have_received(:get).with("invoices/#{invoice_id}/line-items", anything)
    end

    it 'requests the JSON-LD representation' do
      line_items.list invoice_id: invoice_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      line_items.list invoice_id: invoice_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'does not send invoice_id as a query param' do
      line_items.list invoice_id: invoice_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      line_items.list invoice_id: invoice_id, id_lt: 'li_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'li_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      line_items.list invoice_id: invoice_id, id_gt: 'li_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'li_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      line_items.list invoice_id: invoice_id, items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'requests cursor pagination style when asked' do
      line_items.list invoice_id: invoice_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      line_items.list invoice_id: invoice_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(line_items.list(invoice_id: invoice_id)).to be(response)
    end
  end
end
