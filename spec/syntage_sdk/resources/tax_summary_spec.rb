# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::TaxSummary do
  subject(:tax_summary) { described_class.new entity_id, client }

  let(:entity_id) { 'ent_123' }
  let(:client) { instance_double SyntageSdk::Client }
  let(:year) { 2026 }
  let(:invoice_pages) { [[]] }
  let(:retention_pages) { [[]] }
  let(:tax_return_members) { [] }

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

  def retention(items, issued_at: '2026-01-15')
    { 'items' => items, 'issuedAt' => issued_at }
  end

  def tax_return(period:, presented_at:, paid_amount: nil, due_amount: nil, type: 'Normal')
    { 'period' => period, 'presentedAt' => presented_at, 'type' => type,
      'payment' => { 'paidAmount' => paid_amount, 'dueAmount' => due_amount } }
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
      elsif path == "entities/#{entity_id}/tax-returns"
        response_for tax_return_members
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

  describe '#monthly' do
    it 'requests the tax retentions for the given calendar year' do
      tax_summary.monthly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/tax-retentions",
              hash_including(query: hash_including('issuedAt[after]' => '2026-01-01',
                                                     'issuedAt[strictly_before]' => '2027-01-01')))
    end

    it 'requests the monthly tax returns for the given fiscal year' do
      tax_summary.monthly year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/tax-returns",
              hash_including(query: hash_including('intervalUnit' => 'Mensual', 'fiscalYear' => year)))
    end

    it 'buckets retained ISR under the month it was issued in' do
      retention_pages[0] = [retention([{ 'taxType' => '01', 'retainedAmount' => 10 }], issued_at: '2026-03-05')]

      expect(tax_summary.monthly(year: year)['Marzo'][:isr_retained]).to eq(10.0)
    end

    it 'ignores non-ISR retention types when summing the monthly total' do
      retention_pages[0] = [retention([{ 'taxType' => '02', 'retainedAmount' => 20 }], issued_at: '2026-03-05')]

      expect(tax_summary.monthly(year: year)['Marzo'][:isr_retained]).to eq(0.0)
    end

    it 'rounds the retained ISR total to two decimal places' do
      retention_pages[0] = [retention([{ 'taxType' => '01', 'retainedAmount' => 10.005 }], issued_at: '2026-03-05')]

      expect(tax_summary.monthly(year: year)['Marzo'][:isr_retained]).to eq(10.01)
    end

    it 'uses the paid amount of the declared tax return as the enterado figure' do
      tax_return_members.replace [tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 8.5)]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(8.5)
    end

    it 'rounds the enterado figure to two decimal places' do
      tax_return_members.replace [
        tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 8.505)
      ]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(8.51)
    end

    it 'falls back to the due amount when the return has no paid amount yet' do
      tax_return_members.replace [tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', due_amount: 9.1)]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(9.1)
    end

    it 'uses the most recently presented return when a period has more than one' do
      tax_return_members.replace [
        tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 8.5),
        tax_return(period: 'Marzo', presented_at: '2026-05-02T10:00:00Z', paid_amount: 11.0)
      ]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(11.0)
    end

    it 'falls back to an earlier return when the most recent one has no payment amount' do
      tax_return_members.replace [
        tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 8.5),
        tax_return(period: 'Marzo', presented_at: '2026-05-02T10:00:00Z')
      ]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(8.5)
    end

    it 'prefers the complementary return over the normal one when presentedAt ties' do
      tax_return_members.replace [
        tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 67_939.33, type: 'Normal'),
        tax_return(period: 'Marzo', presented_at: '2026-04-17T10:00:00Z', paid_amount: 42_063.01,
                   type: 'Complementaria')
      ]

      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to eq(42_063.01)
    end

    it 'leaves the enterado figure nil for a month with no declared tax return' do
      expect(tax_summary.monthly(year: year)['Marzo'][:tax_return_payment]).to be_nil
    end

    it 'returns every month of the year as a key' do
      expect(tax_summary.monthly(year: year).keys).to contain_exactly(
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      )
    end
  end
end
