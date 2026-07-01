# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxReturns < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        type:             'type',
        interval_unit:    'intervalUnit',
        complementary:    'complementary',
        capture_line:     'captureLine',
        operation_number: 'operationNumber',
        fiscal_year:      'fiscalYear',
        period:           'period'
      }.freeze

      EXTRA_DATE_FIELDS = {
        presented_at: 'presentedAt'
      }.freeze

      ORDER_FIELDS = {
        period:       'period',
        presented_at: 'presentedAt'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        dates:   EXTRA_DATE_FIELDS,
        orders:  ORDER_FIELDS
      ).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/tax-returns", LIST, options
      end

      def retrieve(id)
        retrieve_resource "tax-returns/#{id}"
      end

      def data(id)
        client.get "tax-returns/#{id}/data", headers: { 'Accept' => 'application/json' }
      end
    end
  end
end
