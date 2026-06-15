# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Invoices do
  subject(:invoices) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { 'ent_abc123' }

  describe '#list' do
    it 'gets the entity invoices path' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get).with("entities/#{entity_id}/invoices", anything)
    end

    it 'requests the JSON-LD representation' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the uuid filter' do
      invoices.list entity_id: entity_id, uuid: 'some-uuid'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('uuid' => 'some-uuid')))
    end

    it 'forwards the version filter' do
      invoices.list entity_id: entity_id, version: '4.0'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('version' => '4.0')))
    end

    it 'forwards the type filter' do
      invoices.list entity_id: entity_id, type: 'I'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'I')))
    end

    it 'maps payment_type to the camelCase param' do
      invoices.list entity_id: entity_id, payment_type: '01'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('paymentType' => '01')))
    end

    it 'maps payment_method to the camelCase param' do
      invoices.list entity_id: entity_id, payment_method: 'PUE'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('paymentMethod' => 'PUE')))
    end

    it 'maps issuer_rfc to the dotted param' do
      invoices.list entity_id: entity_id, issuer_rfc: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuer.rfc' => 'XAXX010101000')))
    end

    it 'maps issuer_tax_regime to the dotted camelCase param' do
      invoices.list entity_id: entity_id, issuer_tax_regime: '601'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuer.taxRegime' => '601')))
    end

    it 'maps issuer_blacklist_status to the dotted camelCase param' do
      invoices.list entity_id: entity_id, issuer_blacklist_status: 'blacklisted'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuer.blacklistStatus' => 'blacklisted')))
    end

    it 'maps is_issuer to the camelCase param' do
      invoices.list entity_id: entity_id, is_issuer: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('isIssuer' => true)))
    end

    it 'maps receiver_rfc to the dotted param' do
      invoices.list entity_id: entity_id, receiver_rfc: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('receiver.rfc' => 'XAXX010101000')))
    end

    it 'maps receiver_blacklist_status to the dotted camelCase param' do
      invoices.list entity_id: entity_id, receiver_blacklist_status: 'blacklisted'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('receiver.blacklistStatus' => 'blacklisted')))
    end

    it 'maps is_receiver to the camelCase param' do
      invoices.list entity_id: entity_id, is_receiver: false

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('isReceiver' => false)))
    end

    it 'forwards the currency filter' do
      invoices.list entity_id: entity_id, currency: 'MXN'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('currency' => 'MXN')))
    end

    it 'forwards the status filter' do
      invoices.list entity_id: entity_id, status: 'active'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'active')))
    end

    it 'maps cancellation_status to the camelCase param' do
      invoices.list entity_id: entity_id, cancellation_status: 'pending'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('cancellationStatus' => 'pending')))
    end

    it 'maps has_xml to the camelCase param' do
      invoices.list entity_id: entity_id, has_xml: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('hasXml' => true)))
    end

    it 'maps has_pdf to the camelCase param' do
      invoices.list entity_id: entity_id, has_pdf: false

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('hasPdf' => false)))
    end

    it 'maps exists_payment_method to the bracketed param' do
      invoices.list entity_id: entity_id, exists_payment_method: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('exists[paymentMethod]' => true)))
    end

    it 'maps id_lt to the bracketed param' do
      invoices.list entity_id: entity_id, id_lt: 500

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 500)))
    end

    it 'maps id_gt to the bracketed param' do
      invoices.list entity_id: entity_id, id_gt: 100

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 100)))
    end

    it 'maps total with gt operator to the bracketed param' do
      invoices.list entity_id: entity_id, total: { gt: 1000 }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('total[gt]' => 1000)))
    end

    it 'maps subtotal with lte operator to the bracketed param' do
      invoices.list entity_id: entity_id, subtotal: { lte: 500 }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('subtotal[lte]' => 500)))
    end

    it 'maps tax with between operator to the bracketed param' do
      invoices.list entity_id: entity_id, tax: { between: '100..200' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('tax[between]' => '100..200')))
    end

    it 'maps paid_amount to the camelCase bracketed param' do
      invoices.list entity_id: entity_id, paid_amount: { gte: 0 }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('paidAmount[gte]' => 0)))
    end

    it 'omits numeric operators that are not given' do
      invoices.list entity_id: entity_id, total: { gt: 100 }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('total[lt]')))
    end

    it 'omits numeric fields that are not given' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('total[gt]')))
    end

    it 'maps issued_at date filter to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, issued_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuedAt[after]' => '2026-01-01')))
    end

    it 'maps canceled_at date filter to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, canceled_at: { before: '2026-06-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('canceledAt[before]' => '2026-06-01')))
    end

    it 'maps certified_at date filter to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, certified_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('certifiedAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps last_payment_date filter to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, last_payment_date: { strictly_before: '2026-03-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('lastPaymentDate[strictly_before]' => '2026-03-01')))
    end

    it 'maps fully_paid_at date filter to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, fully_paid_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('fullyPaidAt[after]' => '2026-01-01')))
    end

    it 'omits extra date filters that are not given' do
      invoices.list entity_id: entity_id, issued_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('issuedAt[before]')))
    end

    it 'maps created_at filters to bracketed params' do
      invoices.list entity_id: entity_id, created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps order issued_at to the bracketed camelCase param' do
      invoices.list entity_id: entity_id, order: { issued_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[issuedAt]' => 'desc')))
    end

    it 'maps order amount to the bracketed param' do
      invoices.list entity_id: entity_id, order: { amount: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[amount]' => 'asc')))
    end

    it 'omits order when not given' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('order[issuedAt]')))
    end

    it 'maps items_per_page to the camelCase param' do
      invoices.list entity_id: entity_id, items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'forwards the offset page' do
      invoices.list entity_id: entity_id, page: 2

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 2)))
    end

    it 'forwards the cursor_next token' do
      invoices.list entity_id: entity_id, cursor_next: 'tok_abc'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('cursor_next' => 'tok_abc')))
    end

    it 'requests cursor pagination style when asked' do
      invoices.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'omits the pagination style header by default' do
      invoices.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_excluding('X-Pagination-Style')))
    end

    it 'ignores unknown filters' do
      invoices.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(invoices.list(entity_id: entity_id)).to be(response)
    end
  end
end
