# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxSummary do
  subject(:tax_summary) { described_class.new entity_id, client }

  let(:entity_id) { 'ent_123' }
  let(:client) { instance_double SyntageSdk::Client }
  let(:year) { 2026 }
  let(:invoice_pages) { [[]] }
  let(:retention_pages) { [[]] }

  def response_for(members)
    instance_double SyntageSdk::Response, body: { 'hydra:member' => members }
  end

  def invoice(subtotal: 0, taxes: [], local_taxes: nil)
    {
      'subtotal'         => subtotal,
      'transferredTaxes' => { 'localTaxes' => local_taxes },
      'items'            => [{ 'taxes' => taxes }]
    }
  end

  def retention(items)
    { 'items' => items }
  end

  def page_index(query)
    return 1 if query['id[gt]']

    0
  end

  before do
    allow(client).to receive(:get) do |path, query:, **|
      if path == "entities/#{entity_id}/invoices"
        response_for(invoice_pages[page_index(query)] || [])
      elsif path == "entities/#{entity_id}/tax-retentions"
        response_for(retention_pages[page_index(query)] || [])
      end
    end
  end

  describe '#yearly' do
    it 'requests the invoices for the given calendar year' do
      tax_summary.yearly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices",
              hash_including(query: hash_including('issuedAt[after]' => '2026-01-01',
                                                     'issuedAt[strictly_before]' => '2027-01-01')))
    end

    it 'requests the tax retentions for the given calendar year' do
      tax_summary.yearly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/tax-retentions",
              hash_including(query: hash_including('issuedAt[after]' => '2026-01-01',
                                                     'issuedAt[strictly_before]' => '2027-01-01')))
    end

    it 'sums the subtotal across invoices' do
      invoice_pages[0] = [invoice(subtotal: 100), invoice(subtotal: 50)]

      expect(tax_summary.yearly(year: year)[:subtotal]).to eq(150.0)
    end

    it 'sums the transferred IVA from invoice item taxes' do
      invoice_pages[0] = [invoice(taxes: [{ 'tax' => '002', 'type' => 'transfer', 'amount' => 16 }])]

      expect(tax_summary.yearly(year: year)[:iva]).to eq(16.0)
    end

    it 'sums the transferred IEPS from invoice item taxes' do
      invoice_pages[0] = [invoice(taxes: [{ 'tax' => '003', 'type' => 'transfer', 'amount' => 8 }])]

      expect(tax_summary.yearly(year: year)[:ieps]).to eq(8.0)
    end

    it 'ignores non-transfer item taxes when summing IVA' do
      invoice_pages[0] = [invoice(taxes: [{ 'tax' => '002', 'type' => 'retention', 'amount' => 16 }])]

      expect(tax_summary.yearly(year: year)[:iva]).to eq(0.0)
    end

    it 'sums the ISH from the invoice transferred local taxes' do
      invoice_pages[0] = [invoice(local_taxes: 12.5)]

      expect(tax_summary.yearly(year: year)[:ish]).to eq(12.5)
    end

    it 'treats a missing local taxes value as zero' do
      invoice_pages[0] = [invoice]

      expect(tax_summary.yearly(year: year)[:ish]).to eq(0.0)
    end

    it 'sums the retained IVA from tax retention items' do
      retention_pages[0] = [retention([{ 'taxType' => '02', 'retainedAmount' => 20 }])]

      expect(tax_summary.yearly(year: year)[:ret_iva]).to eq(20.0)
    end

    it 'sums the retained ISR from tax retention items' do
      retention_pages[0] = [retention([{ 'taxType' => '01', 'retainedAmount' => 10 }])]

      expect(tax_summary.yearly(year: year)[:isr_ret]).to eq(10.0)
    end

    it 'ignores unrelated retention tax types' do
      retention_pages[0] = [retention([{ 'taxType' => '03', 'retainedAmount' => 5 }])]

      totals = tax_summary.yearly year: year

      expect(totals.values_at(:ret_iva, :isr_ret)).to eq([0.0, 0.0])
    end

    it 'requests a second page of invoices once a full page is returned' do
      invoice_pages[0] = Array.new(200) { |i| invoice(subtotal: i).merge('id' => "inv-#{i}") }

      tax_summary.yearly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices", hash_including(query: hash_including('id[gt]' => 'inv-199')))
    end

    it 'requests a second page of tax retentions once a full page is returned' do
      retention_pages[0] = Array.new(200) { |i| retention([]).merge('id' => "ret-#{i}") }

      tax_summary.yearly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/tax-retentions", hash_including(query: hash_including('id[gt]' => 'ret-199')))
    end

    it 'returns a hash with every tax total' do
      expect(tax_summary.yearly(year: year).keys).to contain_exactly(:subtotal, :iva, :ieps, :ish, :ret_iva, :isr_ret)
    end
  end
end
