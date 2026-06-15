# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Invoices < BaseResource
      include Listable

      FILTERS = {
        uuid:                        'uuid',
        version:                     'version',
        type:                        'type',
        usage:                       'usage',
        payment_type:                'paymentType',
        payment_method:              'paymentMethod',
        issuer_rfc:                  'issuer.rfc',
        issuer_name:                 'issuer.name',
        issuer_tax_regime:           'issuer.taxRegime',
        issuer_blacklist_status:     'issuer.blacklistStatus',
        is_issuer:                   'isIssuer',
        receiver_rfc:                'receiver.rfc',
        receiver_name:               'receiver.name',
        receiver_blacklist_status:   'receiver.blacklistStatus',
        is_receiver:                 'isReceiver',
        currency:                    'currency',
        status:                      'status',
        pac:                         'pac',
        cancellation_status:         'cancellationStatus',
        cancellation_status_process: 'cancellationStatusProcess',
        has_xml:                     'hasXml',
        has_pdf:                     'hasPdf',
        exists_payment_method:       'exists[paymentMethod]',
        id_lt:                       'id[lt]',
        id_gt:                       'id[gt]'
      }.freeze

      NUMERIC_FIELDS = {
        tax:         'tax',
        discount:    'discount',
        subtotal:    'subtotal',
        total:       'total',
        paid_amount: 'paidAmount',
        due_amount:  'dueAmount'
      }.freeze

      NUMERIC_OPERATORS = %i[gt gte lt lte between].freeze

      ORDER_FIELDS = {
        issued_at:    'issuedAt',
        canceled_at:  'canceledAt',
        certified_at: 'certifiedAt',
        amount:       'amount'
      }.freeze

      EXTRA_DATE_FIELDS = {
        issued_at:         'issuedAt',
        canceled_at:       'canceledAt',
        updated_at:        'updatedAt',
        certified_at:      'certifiedAt',
        last_payment_date: 'lastPaymentDate',
        fully_paid_at:     'fullyPaidAt'
      }.freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/invoices", FILTERS, options
      end

      private

      def list_query(filter_map, options)
        mapped_query(filter_map, options)
          .merge(mapped_query(PAGINATION_PARAMS, options))
          .merge(date_query(options.fetch(:created_at, {})))
          .merge(extra_date_queries(options))
          .merge(numeric_range_query(options))
          .merge(invoice_order_query(options[:order]))
      end

      def extra_date_queries(options)
        EXTRA_DATE_FIELDS.each_with_object({}) do |(key, field), query|
          dates = options.fetch(key, {})
          DATE_FILTERS.each do |filter|
            value = dates[filter]
            next if value.nil?

            query["#{field}[#{filter}]"] = value
          end
        end
      end

      def numeric_range_query(options)
        NUMERIC_FIELDS.each_with_object({}) do |(key, param), query|
          ranges = options[key]
          next if ranges.nil?

          NUMERIC_OPERATORS.each do |op|
            query["#{param}[#{op}]"] = ranges[op] unless ranges[op].nil?
          end
        end
      end

      def invoice_order_query(order)
        return {} if order.nil?

        ORDER_FIELDS.each_with_object({}) do |(key, param), query|
          value = order[key]
          next if value.nil?

          query["order[#{param}]"] = value
        end
      end
    end
  end
end
