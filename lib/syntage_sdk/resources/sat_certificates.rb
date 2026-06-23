# frozen_string_literal: true

module SyntageSdk
  module Resources
    class SatCertificates < EntityScopedResource
      include Listable
      include Retrievable

      FILTERS = {
        serial_number: 'serialNumber',
        type:          'type'
      }.freeze

      EXTRA_DATE_FIELDS = {
        valid_from: 'validFrom',
        valid_to:   'validTo'
      }.freeze

      ORDER_FIELDS = {
        valid_from: 'validFrom',
        valid_to:   'validTo'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS, dates: EXTRA_DATE_FIELDS, orders: ORDER_FIELDS).freeze

      def list(**options)
        list_collection "entities/#{entity_id}/datasources/mx/sat/certificados", LIST, options
      end

      def retrieve(id)
        retrieve_resource "datasources/mx/sat/certificados/#{id}"
      end
    end
  end
end
