# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxReturns do
  subject(:tax_returns) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }
  let(:entity_id) { 'ent_abc123' }

  describe '#list' do
    it 'gets the entity tax-returns path' do
      tax_returns.list entity_id: entity_id

      expect(client).to have_received(:get).with("entities/#{entity_id}/tax-returns", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_returns.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      tax_returns.list entity_id: entity_id

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the type filter' do
      tax_returns.list entity_id: entity_id, type: 'Normal'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'Normal')))
    end

    it 'maps interval_unit to the camelCase param' do
      tax_returns.list entity_id: entity_id, interval_unit: 'Mensual'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('intervalUnit' => 'Mensual')))
    end

    it 'forwards the complementary filter' do
      tax_returns.list entity_id: entity_id, complementary: 'Modificación de Declaración'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('complementary' => 'Modificación de Declaración')))
    end

    it 'maps capture_line to the camelCase param' do
      tax_returns.list entity_id: entity_id, capture_line: '02261SO6079979624079'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('captureLine' => '02261SO6079979624079')))
    end

    it 'maps operation_number to the camelCase param' do
      tax_returns.list entity_id: entity_id, operation_number: '445245071'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('operationNumber' => '445245071')))
    end

    it 'maps fiscal_year to the camelCase param' do
      tax_returns.list entity_id: entity_id, fiscal_year: 2025

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('fiscalYear' => 2025)))
    end

    it 'forwards the period filter' do
      tax_returns.list entity_id: entity_id, period: 'Enero'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('period' => 'Enero')))
    end

    it 'maps presented_at date filter to the bracketed camelCase param' do
      tax_returns.list entity_id: entity_id, presented_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('presentedAt[after]' => '2026-01-01')))
    end

    it 'maps created_at filters to bracketed params' do
      tax_returns.list entity_id: entity_id, created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps order period to the bracketed param' do
      tax_returns.list entity_id: entity_id, order: { period: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[period]' => 'asc')))
    end

    it 'maps order presented_at to the bracketed camelCase param' do
      tax_returns.list entity_id: entity_id, order: { presented_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[presentedAt]' => 'desc')))
    end

    it 'maps items_per_page to the camelCase param' do
      tax_returns.list entity_id: entity_id, items_per_page: 25

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 25)))
    end

    it 'forwards the offset page' do
      tax_returns.list entity_id: entity_id, page: 3

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 3)))
    end

    it 'requests cursor pagination style when asked' do
      tax_returns.list entity_id: entity_id, cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'omits the pagination style header by default' do
      tax_returns.list entity_id: entity_id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_excluding('X-Pagination-Style')))
    end

    it 'ignores unknown filters' do
      tax_returns.list entity_id: entity_id, bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(tax_returns.list(entity_id: entity_id)).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { 'a1fbecf9-0330-4821-886c-7d45da9c29f4' }

    it 'gets the global tax-returns path' do
      tax_returns.retrieve id

      expect(client).to have_received(:get).with("tax-returns/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      tax_returns.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'does not send query params' do
      tax_returns.retrieve id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(tax_returns.retrieve(id)).to be(response)
    end
  end

  describe '#data' do
    let(:id) { 'a1fbecf9-0330-4821-886c-7d45da9c29f4' }

    it 'gets the tax-return data path' do
      tax_returns.data id

      expect(client).to have_received(:get).with("tax-returns/#{id}/data", anything)
    end

    it 'requests the JSON representation' do
      tax_returns.data id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: { 'Accept' => 'application/json' }))
    end

    it 'does not send query params' do
      tax_returns.data id

      expect(client).to have_received(:get).with(anything, hash_excluding(:query))
    end

    it 'returns the client response' do
      expect(tax_returns.data(id)).to be(response)
    end
  end
end
