# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Invoices < BaseResource
      include Listable
      include Retrievable

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

      def retrieve(id)
        retrieve_resource "invoices/#{id}"
      end

      private

      def list_query(filter_map, options)
        super
          .merge(extra_date_queries(options))
          .merge numeric_range_query(options)
      end

      def order_query(order)
        return {} if order.nil?

        order.slice(*ORDER_FIELDS.keys).compact.each_with_object({}) do |(key, value), query|
          query["order[#{ORDER_FIELDS[key]}]"] = value
        end
      end

      def extra_date_queries(options)
        EXTRA_DATE_FIELDS.each_with_object({}) do |(key, field), query|
          query.merge! date_field_query(field, options.fetch(key, {}))
        end
      end

      def numeric_range_query(options)
        NUMERIC_FIELDS.each_with_object({}) do |(key, param), query|
          query.merge! numeric_field_query(param, options[key])
        end
      end

      def numeric_field_query(param, ranges)
        return {} if ranges.nil?

        ranges.slice(*NUMERIC_OPERATORS).compact.each_with_object({}) do |(op, value), query|
          query["#{param}[#{op}]"] = value
        end
      end
    end
  end
end
