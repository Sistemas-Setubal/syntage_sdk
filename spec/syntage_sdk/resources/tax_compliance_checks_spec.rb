# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxComplianceChecks do
  subject(:tax_compliance_checks) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { 'ent_abc123' }

  describe '#list' do
    it 'gets the entity tax-compliance-checks path' do
      tax_compliance_checks.list entity_id: entity_id

      expect(client).to have_received(:get).with("entities/#{entity_id}/tax-compliance-checks", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_compliance_checks.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      tax_compliance_checks.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps internal_identifier to the camelCase param' do
      tax_compliance_checks.list entity_id: entity_id, internal_identifier: 'ABC123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('internalIdentifier' => 'ABC123')))
    end

    it 'maps taxpayer_rfc to the dotted param' do
      tax_compliance_checks.list entity_id: entity_id, taxpayer_rfc: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.rfc' => 'XAXX010101000')))
    end

    it 'maps taxpayer_name to the dotted param' do
      tax_compliance_checks.list entity_id: entity_id, taxpayer_name: 'Acme'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.name' => 'Acme')))
    end

    it 'forwards the result filter' do
      tax_compliance_checks.list entity_id: entity_id, result: 'positive'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('result' => 'positive')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      tax_compliance_checks.list entity_id: entity_id, id_lt: 'tcc_500'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'tcc_500')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      tax_compliance_checks.list entity_id: entity_id, id_gt: 'tcc_100'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'tcc_100')))
    end

    it 'maps checked_at date filter to the bracketed camelCase param' do
      tax_compliance_checks.list entity_id: entity_id, checked_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('checkedAt[after]' => '2026-01-01')))
    end

    it 'maps created_at filters to bracketed params' do
      tax_compliance_checks.list entity_id: entity_id, created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps order checked_at to the bracketed camelCase param' do
      tax_compliance_checks.list entity_id: entity_id, order: { checked_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[checkedAt]' => 'desc')))
    end

    it 'maps order created_at to the bracketed camelCase param' do
      tax_compliance_checks.list entity_id: entity_id, order: { created_at: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      tax_compliance_checks.list entity_id: entity_id, items_per_page: 25

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 25)))
    end

    it 'requests cursor pagination style when asked' do
      tax_compliance_checks.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'ignores unknown filters' do
      tax_compliance_checks.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(tax_compliance_checks.list(entity_id: entity_id)).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { '91106968-1abd-4d64-85c1-4e73d96fb997' }

    it 'gets the singular tax-compliance-checks path' do
      tax_compliance_checks.retrieve id

      expect(client).to have_received(:get).with("tax-compliance-checks/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_compliance_checks.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      tax_compliance_checks.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(tax_compliance_checks.retrieve(id)).to be(response)
    end
  end
end
