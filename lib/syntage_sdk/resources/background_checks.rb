# frozen_string_literal: true

module SyntageSdk
  module Resources
    class BackgroundChecks < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        status:  'status',
        country: 'country',
        id_lt:   'id[lt]',
        id_gt:   'id[gt]'
      }.freeze

      ORDER_FIELDS = {
        score:      'score',
        created_at: 'createdAt',
        updated_at: 'updatedAt'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS, orders: ORDER_FIELDS).freeze

      RECORDS = ListConfig.new(
        filters: { category: 'category', id_lt: 'id[lt]', id_gt: 'id[gt]' },
        orders:  { created_at: 'createdAt', updated_at: 'updatedAt' }
      ).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/background-checks", LIST, options
      end

      def list_all(**options)
        list_collection 'background-checks', LIST, options
      end

      def retrieve(id)
        retrieve_resource "background-checks/#{id}"
      end

      def pdf(id)
        retrieve_resource "background-checks/#{id}/pdf"
      end

      def records(id, **options)
        list_collection "background-checks/#{id}/records", RECORDS, options
      end
    end
  end
end
