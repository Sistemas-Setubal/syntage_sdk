# frozen_string_literal: true

module SyntageSdk
  module Resources
    class InvoiceTotals < EntityScopedResource
      include CursorPaging

      ACTIVE = 'VIGENTE'
      TYPES = { 'I' => :income, 'E' => :credit_note }.freeze

      ROLES = { issued: :is_issuer, received: :is_receiver }.freeze

      ZONE_OFFSET = '-06:00'

      EMPTY = { income_subtotal: 0.0, income_discount: 0.0, credited_amount: 0.0, credit_notes: 0.0,
                 invoices_count: 0 }.freeze

      def annual(year:)
        date_filter = { after: start_of(year), strictly_before: start_of(year + 1) }

        ROLES.transform_values { |role| totals date_filter, role }
      end

      private

      def start_of(year)
        "#{year}-01-01T00:00:00#{ZONE_OFFSET}"
      end

      def totals(date_filter, role)
        found = EMPTY.dup
        filters = { status: ACTIVE, role => true }

        each_page Invoices.new(client), date_filter, **filters do |invoice|
          add found, invoice
        end

        summarize found
      end

      def add(found, invoice)
        contribution = contribution_of invoice
        return unless contribution

        contribution.each { |total, amount| found[total] += amount }
        found[:invoices_count] += 1
      end

      def contribution_of(invoice)
        subtotal = invoice['subtotal'].to_f
        discount = invoice['discount'].to_f

        case TYPES[invoice['type']]
        when :income then income_of invoice, subtotal, discount
        when :credit_note then { credit_notes: subtotal - discount }
        end
      end

      def income_of(invoice, subtotal, discount)
        { income_subtotal: subtotal, income_discount: discount,
          credited_amount: invoice['subtotalCreditedAmount'].to_f }
      end

      def summarize(found)
        amounts = found.except :invoices_count

        amounts.merge(net: net(amounts))
               .transform_values { |amount| amount.round 2 }
               .merge(invoices_count: found[:invoices_count])
      end

      def net(amounts)
        amounts[:income_subtotal] - amounts[:income_discount] - amounts[:credited_amount]
      end
    end
  end
end
