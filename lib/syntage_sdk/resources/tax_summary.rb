# frozen_string_literal: true

require 'date'

module SyntageSdk
  module Resources
    class TaxSummary < EntityScopedResource
      PAGE_SIZE = 200

      MONTH_NAMES = %w[
        Enero Febrero Marzo Abril Mayo Junio
        Julio Agosto Septiembre Octubre Noviembre Diciembre
      ].freeze

      TRANSFER_TOTALS = { '002' => :iva, '003' => :ieps }.freeze
      RETENTION_TOTALS = { '02' => :ret_iva, '01' => :isr_ret }.freeze

      def yearly(year:)
        date_filter = { after: "#{year}-01-01", strictly_before: "#{year + 1}-01-01" }

        invoice_totals(date_filter).merge retention_totals(date_filter)
      end

      def monthly(year:)
        retained = monthly_isr_retained year
        declared = monthly_declared_payments year

        MONTH_NAMES.each_with_object({}) do |month, totals|
          totals[month] = { isr_retained: (retained[month] || 0.0).round(2),
                             tax_return_payment: declared[month]&.round(2) }
        end
      end

      private

      def tax_retentions
        TaxRetentions.new client
      end

      def invoice_totals(date_filter)
        totals = { subtotal: 0.0, iva: 0.0, ieps: 0.0, ish: 0.0 }

        each_page Invoices.new(client), date_filter do |invoice|
          totals[:subtotal] += invoice['subtotal'].to_f
          totals[:ish] += invoice.dig('transferredTaxes', 'localTaxes').to_f
          add_invoice_item_taxes totals, invoice['items'] || []
        end

        totals
      end

      def add_invoice_item_taxes(totals, items)
        items.flat_map { |item| item['taxes'] || [] }.each do |tax|
          next unless tax['type'] == 'transfer'

          key = TRANSFER_TOTALS[tax['tax']]
          next unless key

          totals[key] += tax['amount'].to_f
        end
      end

      def retention_totals(date_filter)
        totals = { ret_iva: 0.0, isr_ret: 0.0 }

        each_page tax_retentions, date_filter do |retention|
          add_retention_items totals, retention['items'] || []
        end

        totals
      end

      def add_retention_items(totals, items)
        items.each { |item| add_retained_tax totals, item }
      end

      def add_retained_tax(totals, item)
        key = RETENTION_TOTALS[item['taxType']]
        return unless key

        totals[key] += item['retainedAmount'].to_f
      end

      def monthly_isr_retained(year)
        date_filter = { after: "#{year}-01-01", strictly_before: "#{year + 1}-01-01" }
        totals = Hash.new 0.0

        each_page tax_retentions, date_filter do |retention|
          month = MONTH_NAMES[Date.parse(retention['issuedAt']).month - 1]
          totals[month] += isr_retained_amount(retention['items'] || [])
        end

        totals
      end

      def isr_retained_amount(items)
        items.sum do |item|
          next 0.0 unless item['taxType'] == '01'

          item['retainedAmount'].to_f
        end
      end

      def monthly_declared_payments(year)
        options = { entity_id: entity_id, interval_unit: 'Mensual', fiscal_year: year, items_per_page: 100 }
        members = TaxReturns.new(client).list(**options).body['hydra:member'] || []

        members.group_by { |tax_return| tax_return['period'] }
               .transform_values { |returns| latest_payment_amount returns }
      end

      def latest_payment_amount(returns)
        ranked = returns.sort_by { |tax_return| [tax_return['presentedAt'], complementary_rank(tax_return)] }.reverse

        amounts = ranked.filter_map do |tax_return|
          tax_return.dig('payment', 'paidAmount') || tax_return.dig('payment', 'dueAmount')
        end

        amounts.first
      end

      def complementary_rank(tax_return)
        return 1 if tax_return['type'].to_s.start_with? 'Complementaria'

        0
      end

      def each_page(resource, date_filter)
        cursor = nil

        loop do
          members = fetch_page resource, date_filter, cursor
          break if members.empty?

          members.each { |member| yield member }
          break if members.size < PAGE_SIZE

          cursor = members.last['id']
        end
      end

      def fetch_page(resource, date_filter, cursor)
        options = { entity_id: entity_id, items_per_page: PAGE_SIZE, cursor: true, issued_at: date_filter }
        options[:id_gt] = cursor if cursor

        resource.list(**options).body['hydra:member'] || []
      end
    end
  end
end
