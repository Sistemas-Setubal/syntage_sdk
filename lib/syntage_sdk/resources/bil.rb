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

      MAX_ITEMS_PER_PAGE = 100

      def list(entity_id:, **options)
        validate_items_per_page options[:items_per_page]
        list_collection "entities/#{entity_id}/datasources/bil/reports", LIST, options
      end

      def retrieve(id)
        retrieve_resource "datasources/bil/reports/#{id}"
      end

      private

      def validate_items_per_page(value)
        return if value.nil?
        return if value.is_a?(Integer) && value.between?(1, MAX_ITEMS_PER_PAGE)

        raise ArgumentError,
              "items_per_page must be an integer between 1 and #{MAX_ITEMS_PER_PAGE}, got #{value.inspect}"
      end
    end
  end
end
