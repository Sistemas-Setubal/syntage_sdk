# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxSummary < EntityScopedResource
      PAGE_SIZE = 200

      TRANSFER_TOTALS = { '002' => :iva, '003' => :ieps }.freeze
      RETENTION_TOTALS = { '02' => :ret_iva, '01' => :isr_ret }.freeze

      def yearly(year:)
        date_filter = { after: "#{year}-01-01", strictly_before: "#{year + 1}-01-01" }

        invoice_totals(date_filter).merge retention_totals(date_filter)
      end

      private

      def invoices
        Invoices.new client
      end

      def tax_retentions
        TaxRetentions.new client
      end

      def invoice_totals(date_filter)
        totals = { subtotal: 0.0, iva: 0.0, ieps: 0.0, ish: 0.0 }

        each_page invoices, date_filter do |invoice|
          totals[:subtotal] += invoice['subtotal'].to_f
          totals[:ish] += invoice.dig('transferredTaxes', 'localTaxes').to_f
          add_invoice_item_taxes totals, invoice['items'] || []
        end

        totals
      end

      def add_invoice_item_taxes(totals, items)
        items.flat_map { |item| item['taxes'] || [] }.each { |tax| add_transfer_tax totals, tax }
      end

      def add_transfer_tax(totals, tax)
        return unless tax['type'] == 'transfer'

        key = TRANSFER_TOTALS[tax['tax']]
        return unless key

        totals[key] += tax['amount'].to_f
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
