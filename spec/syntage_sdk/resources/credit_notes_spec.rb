require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::CreditNotes do
  subject(:credit_notes) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the credit notes path' do
      credit_notes.list

      expect(client).to have_received(:get).with('invoices/credit-notes', anything)
    end

    it 'requests the JSON-LD representation' do
      credit_notes.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      credit_notes.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      credit_notes.list id_lt: 'cn_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'cn_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      credit_notes.list id_gt: 'cn_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'cn_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      credit_notes.list items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'requests cursor pagination style when asked' do
      credit_notes.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      credit_notes.list bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(credit_notes.list).to be(response)
    end
  end

  describe '#issued' do
    let(:invoice_id) { 'a1fd895b-5dcb-4cb4-89bc-3467f460c75b' }

    it 'gets the invoice issued credit notes path' do
      credit_notes.issued invoice_id: invoice_id

      expect(client).to have_received(:get).with("invoices/#{invoice_id}/issued-credit-notes", anything)
    end

    it 'requests the JSON-LD representation' do
      credit_notes.issued invoice_id: invoice_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send invoice_id as a query param' do
      credit_notes.issued invoice_id: invoice_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps items_per_page to the camelCase param' do
      credit_notes.issued invoice_id: invoice_id, items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'returns the client response' do
      expect(credit_notes.issued(invoice_id: invoice_id)).to be(response)
    end
  end

  describe '#applied' do
    let(:invoice_id) { 'a1fd895b-5dcb-4cb4-89bc-3467f460c75b' }

    it 'gets the invoice applied credit notes path' do
      credit_notes.applied invoice_id: invoice_id

      expect(client).to have_received(:get).with("invoices/#{invoice_id}/applied-credit-notes", anything)
    end

    it 'requests the JSON-LD representation' do
      credit_notes.applied invoice_id: invoice_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send invoice_id as a query param' do
      credit_notes.applied invoice_id: invoice_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps items_per_page to the camelCase param' do
      credit_notes.applied invoice_id: invoice_id, items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'returns the client response' do
      expect(credit_notes.applied(invoice_id: invoice_id)).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the singular invoice credit note path' do
      credit_notes.retrieve id

      expect(client).to have_received(:get).with("invoices/credit-note/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      credit_notes.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      credit_notes.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(credit_notes.retrieve(id)).to be(response)
    end
  end
end
