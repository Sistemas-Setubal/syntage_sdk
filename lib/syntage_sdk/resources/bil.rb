# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Bil < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      ORDER_FIELDS = {
        created_at: 'createdAt'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS, orders: ORDER_FIELDS).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/datasources/bil/reports", LIST, options
      end

      def retrieve(id)
        retrieve_resource "datasources/bil/reports/#{id}"
      end
    end
  end
end
