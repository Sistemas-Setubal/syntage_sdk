# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::InvoiceTotals do
  subject(:invoice_totals) { described_class.new entity_id, client }

  let(:entity_id) { 'ent_123' }
  let(:client) { instance_double SyntageSdk::Client }
  let(:year) { 2025 }
  let(:issued_pages) { [[]] }
  let(:received_pages) { [[]] }

  def response_for(members)
    instance_double SyntageSdk::Response, body: { 'hydra:member' => members }
  end

  def invoice(type: 'I', subtotal: 0, discount: 0, credited: 0)
    { 'type' => type, 'subtotal' => subtotal, 'discount' => discount, 'subtotalCreditedAmount' => credited }
  end

  def pages_for(query)
    return issued_pages if query['isIssuer']

    received_pages
  end

  def page_index(query)
    return 1 if query['id[lt]']

    0
  end

  before do
    allow(client).to receive(:get) do |_path, query:, **|
      response_for(pages_for(query)[page_index(query)] || [])
    end
  end

  describe '#annual' do
    it 'requests the invoices the entity issued' do
      invoice_totals.annual year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices", hash_including(query: hash_including('isIssuer' => true)))
    end

    it 'requests the invoices the entity received' do
      invoice_totals.annual year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices", hash_including(query: hash_including('isReceiver' => true)))
    end

    it 'asks only for active invoices so cancelled ones never reach the totals' do
      invoice_totals.annual year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices", hash_including(query: hash_including('status' => 'VIGENTE'))).twice
    end

    it 'bounds the year in local time, since issuedAt is the UTC of a local CFDI date' do
      invoice_totals.annual year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices",
              hash_including(query: hash_including('issuedAt[after]' => '2025-01-01T00:00:00-06:00',
                                                     'issuedAt[strictly_before]' => '2026-01-01T00:00:00-06:00')))
        .twice
    end

    it 'sums the subtotal of the income invoices' do
      issued_pages[0] = [invoice(subtotal: 100), invoice(subtotal: 50)]

      expect(invoice_totals.annual(year: year)[:issued][:income_subtotal]).to eq(150.0)
    end

    it 'sums the discount of the income invoices' do
      issued_pages[0] = [invoice(subtotal: 100, discount: 10)]

      expect(invoice_totals.annual(year: year)[:issued][:income_discount]).to eq(10.0)
    end

    it 'sums the credit notes net of their own discount' do
      issued_pages[0] = [invoice(type: 'E', subtotal: 30, discount: 5)]

      expect(invoice_totals.annual(year: year)[:issued][:credit_notes]).to eq(25.0)
    end

    it 'sums the credit applied to the income invoices of the year' do
      issued_pages[0] = [invoice(subtotal: 100, credited: 25)]

      expect(invoice_totals.annual(year: year)[:issued][:credited_amount]).to eq(25.0)
    end

    it 'subtracts discounts and applied credit from the income subtotal to get the net' do
      issued_pages[0] = [invoice(subtotal: 100, discount: 10, credited: 25)]

      expect(invoice_totals.annual(year: year)[:issued][:net]).to eq(65.0)
    end

    it 'leaves the credit notes issued this year out of the net, to avoid counting a credit twice' do
      issued_pages[0] = [invoice(subtotal: 100), invoice(type: 'E', subtotal: 30)]

      expect(invoice_totals.annual(year: year)[:issued][:net]).to eq(100.0)
    end

    it 'counts the income and credit note invoices it added up' do
      issued_pages[0] = [invoice(subtotal: 100), invoice(type: 'E', subtotal: 30)]

      expect(invoice_totals.annual(year: year)[:issued][:invoices_count]).to eq(2)
    end

    it 'ignores payment complements, whose amounts would double count the income' do
      issued_pages[0] = [invoice(type: 'P', subtotal: 100)]

      expect(invoice_totals.annual(year: year)[:issued][:net]).to eq(0.0)
    end

    it 'leaves payment complements out of the invoice count' do
      issued_pages[0] = [invoice(type: 'P', subtotal: 100)]

      expect(invoice_totals.annual(year: year)[:issued][:invoices_count]).to eq(0)
    end

    it 'ignores payroll receipts, which are a deduction rather than income' do
      issued_pages[0] = [invoice(type: 'N', subtotal: 100)]

      expect(invoice_totals.annual(year: year)[:issued][:net]).to eq(0.0)
    end

    it 'keeps the received side apart from the issued one' do
      issued_pages[0] = [invoice(subtotal: 100)]
      received_pages[0] = [invoice(subtotal: 40)]

      expect(invoice_totals.annual(year: year)[:received][:net]).to eq(40.0)
    end

    it 'rounds the totals to two decimal places' do
      issued_pages[0] = [invoice(subtotal: 10.005)]

      expect(invoice_totals.annual(year: year)[:issued][:income_subtotal]).to eq(10.01)
    end

    it 'requests a second page once a full page is returned' do
      issued_pages[0] = Array.new(200) { |i| invoice(subtotal: 1).merge('id' => "inv-#{i}") }

      invoice_totals.annual year: year

      expect(client).to have_received(:get)
        .with("entities/#{entity_id}/invoices", hash_including(query: hash_including('id[lt]' => 'inv-199')))
    end

    it 'adds up the invoices found across pages' do
      issued_pages[0] = Array.new(200) { |i| invoice(subtotal: 1).merge('id' => "inv-#{i}") }
      issued_pages[1] = [invoice(subtotal: 5)]

      expect(invoice_totals.annual(year: year)[:issued][:income_subtotal]).to eq(205.0)
    end

    it 'returns both sides of the invoicing' do
      expect(invoice_totals.annual(year: year).keys).to contain_exactly(:issued, :received)
    end

    it 'returns a hash with every total for a side' do
      expect(invoice_totals.annual(year: year)[:issued].keys)
        .to contain_exactly(:income_subtotal, :income_discount, :credited_amount, :credit_notes, :net,
                              :invoices_count)
    end
  end
end
