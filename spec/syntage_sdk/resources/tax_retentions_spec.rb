# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxRetentions do
  subject(:tax_retentions) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { 'ent_abc123' }

  describe '#list' do
    it 'gets the entity tax-retentions path' do
      tax_retentions.list entity_id: entity_id

      expect(client).to have_received(:get).with("entities/#{entity_id}/tax-retentions", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_retentions.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      tax_retentions.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the uuid filter' do
      tax_retentions.list entity_id: entity_id, uuid: 'a1b2c3'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('uuid' => 'a1b2c3')))
    end

    it 'maps internal_identifier to the camelCase param' do
      tax_retentions.list entity_id: entity_id, internal_identifier: 'ABC123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('internalIdentifier' => 'ABC123')))
    end

    it 'maps issuer_rfc to the dotted param' do
      tax_retentions.list entity_id: entity_id, issuer_rfc: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuer.rfc' => 'XAXX010101000')))
    end

    it 'maps receiver_name to the dotted param' do
      tax_retentions.list entity_id: entity_id, receiver_name: 'Acme'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('receiver.name' => 'Acme')))
    end

    it 'maps has_xml to the camelCase param' do
      tax_retentions.list entity_id: entity_id, has_xml: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('hasXml' => true)))
    end

    it 'maps id_lt to the bracketed cursor param' do
      tax_retentions.list entity_id: entity_id, id_lt: 'ret_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'ret_500')))
    end

    it 'maps total_retained_amount range operators to bracketed params' do
      tax_retentions.list entity_id: entity_id, total_retained_amount: { gte: '100.00' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('totalRetainedAmount[gte]' => '100.00')))
    end

    it 'maps total_operation_amount between operator to the bracketed param' do
      tax_retentions.list entity_id: entity_id, total_operation_amount: { between: '12.99..15.99' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('totalOperationAmount[between]' => '12.99..15.99')))
    end

    it 'maps issued_at date filter to the bracketed camelCase param' do
      tax_retentions.list entity_id: entity_id, issued_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('issuedAt[after]' => '2026-01-01')))
    end

    it 'maps period_to date filter to the bracketed camelCase param' do
      tax_retentions.list entity_id: entity_id, period_to: { strictly_before: '2026-12-31' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('periodTo[strictly_before]' => '2026-12-31')))
    end

    it 'maps created_at filters to bracketed params' do
      tax_retentions.list entity_id: entity_id, created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps order certified_at to the bracketed camelCase param' do
      tax_retentions.list entity_id: entity_id, order: { certified_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[certifiedAt]' => 'desc')))
    end

    it 'maps order total_retained_amount to the bracketed camelCase param' do
      tax_retentions.list entity_id: entity_id, order: { total_retained_amount: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[totalRetainedAmount]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      tax_retentions.list entity_id: entity_id, items_per_page: 25

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 25)))
    end

    it 'requests cursor pagination style when asked' do
      tax_retentions.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      tax_retentions.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(tax_retentions.list(entity_id: entity_id)).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the singular tax-retention path' do
      tax_retentions.retrieve id

      expect(client).to have_received(:get).with("tax-retentions/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_retentions.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      tax_retentions.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(tax_retentions.retrieve(id)).to be(response)
    end
  end

  describe '#cfdi' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the tax-retention cfdi path' do
      tax_retentions.cfdi id

      expect(client).to have_received(:get).with("tax-retentions/#{id}/cfdi", anything)
    end

    it 'requests the JSON representation by default' do
      tax_retentions.cfdi id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'Accept' => 'application/json' }))
    end

    it 'requests the original XML' do
      tax_retentions.cfdi id, format: :xml

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'Accept' => 'text/xml' }))
    end

    it 'requests the PDF' do
      tax_retentions.cfdi id, format: :pdf

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'Accept' => 'application/pdf' }))
    end

    it 'raises on an unsupported format' do
      expect { tax_retentions.cfdi id, format: :csv }.to raise_error(ArgumentError, /csv/)
    end

    it 'does not reach the client on an unsupported format' do
      tax_retentions.cfdi id, format: :csv
    rescue ArgumentError
      expect(client).not_to have_received(:get)
    end

    it 'returns the client response' do
      expect(tax_retentions.cfdi(id)).to be(response)
    end
  end
end
