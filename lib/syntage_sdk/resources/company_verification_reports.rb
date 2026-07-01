# frozen_string_literal: true

module SyntageSdk
  module Resources
    class CompanyVerificationReports < BaseResource
      include Listable
      include Retrievable

      PATH = 'datasources/mx/company-verification/reports'

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      ORDER_FIELDS = {
        created_at: 'createdAt',
        updated_at: 'updatedAt'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS, orders: ORDER_FIELDS).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/#{PATH}", LIST, options
      end

      def list_all(**options)
        list_collection PATH, LIST, options
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end
    end
  end
end
