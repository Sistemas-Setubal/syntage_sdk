require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Payments do
  subject(:payments) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the global invoice payments path' do
      payments.list

      expect(client).to have_received(:get).with('invoices/payments', anything)
    end

    it 'gets a single invoice payments path when invoice_id is given' do
      payments.list invoice_id: 'a1fd895b'

      expect(client).to have_received(:get).with('invoices/a1fd895b/payments', anything)
    end

    it 'does not send invoice_id as a query param' do
      payments.list invoice_id: 'a1fd895b'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'requests the JSON-LD representation' do
      payments.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      payments.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps id_lt to the bracketed cursor param' do
      payments.list id_lt: 'pay_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'pay_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      payments.list id_gt: 'pay_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'pay_100')))
    end

    it 'maps items_per_page to the camelCase param' do
      payments.list items_per_page: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 100)))
    end

    it 'requests cursor pagination style when asked' do
      payments.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      payments.list bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(payments.list).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the invoice payment path' do
      payments.retrieve id

      expect(client).to have_received(:get).with("invoices/payments/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      payments.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      payments.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(payments.retrieve(id)).to be(response)
    end
  end
end
