# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxRetentions < BaseResource
      include Listable
      include Retrievable
      include CfdiRetrievable

      FILTERS = {
        uuid:                 'uuid',
        version:              'version',
        internal_identifier:  'internalIdentifier',
        pac:                  'pac',
        code:                 'code',
        issuer_rfc:           'issuer.rfc',
        issuer_name:          'issuer.name',
        issuer_curp:          'issuer.curp',
        receiver_rfc:         'receiver.rfc',
        receiver_name:        'receiver.name',
        receiver_curp:        'receiver.curp',
        receiver_nationality: 'receiver.nationality',
        has_xml:              'hasXml',
        has_pdf:              'hasPdf',
        id_lt:                'id[lt]',
        id_gt:                'id[gt]'
      }.freeze

      NUMERIC_FIELDS = {
        total_operation_amount: 'totalOperationAmount',
        total_taxable_amount:   'totalTaxableAmount',
        total_exempt_amount:    'totalExemptAmount',
        total_retained_amount:  'totalRetainedAmount'
      }.freeze

      DATE_FIELDS = {
        issued_at:    'issuedAt',
        canceled_at:  'canceledAt',
        certified_at: 'certifiedAt',
        period_from:  'periodFrom',
        period_to:    'periodTo'
      }.freeze

      ORDER_FIELDS = {
        issued_at:              'issuedAt',
        canceled_at:            'canceledAt',
        certified_at:           'certifiedAt',
        period_from:            'periodFrom',
        period_to:              'periodTo',
        total_operation_amount: 'totalOperationAmount',
        total_taxable_amount:   'totalTaxableAmount',
        total_exempt_amount:    'totalExemptAmount',
        total_retained_amount:  'totalRetainedAmount'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        numeric: NUMERIC_FIELDS,
        dates:   DATE_FIELDS,
        orders:  ORDER_FIELDS
      ).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/tax-retentions", LIST, options
      end

      def retrieve(id)
        retrieve_resource "tax-retentions/#{id}"
      end

      def cfdi(id, format: :json)
        retrieve_cfdi "tax-retentions/#{id}/cfdi", format
      end
    end
  end
end
