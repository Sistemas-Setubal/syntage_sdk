# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxComplianceChecks < BaseResource
      include Listable

      FILTERS = {
        internal_identifier: 'internalIdentifier',
        taxpayer_rfc:        'taxpayer.rfc',
        taxpayer_name:       'taxpayer.name',
        result:              'result',
        id_lt:               'id[lt]',
        id_gt:               'id[gt]'
      }.freeze

      EXTRA_DATE_FIELDS = {
        checked_at: 'checkedAt'
      }.freeze

      ORDER_FIELDS = {
        checked_at: 'checkedAt',
        created_at: 'createdAt'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        dates:   EXTRA_DATE_FIELDS,
        orders:  ORDER_FIELDS
      ).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/tax-compliance-checks", LIST, options
      end
    end
  end
end
