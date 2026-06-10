# frozen_string_literal: true

module SyntageSdk
  module Resources
    module Listable
      LD_JSON = 'application/ld+json'

      PAGINATION_PARAMS = {
        items_per_page: 'itemsPerPage',
        page: 'page',
        cursor_next: 'cursor_next',
        cursor_previous: 'cursor_previous'
      }.freeze

      DATE_FILTERS = %i[before after strictly_before strictly_after].freeze

      private

      def list_collection(path, filter_map, options)
        client.get path, query: list_query(filter_map, options), headers: list_headers(options)
      end

      def list_query(filter_map, options)
        mapped_query(filter_map, options)
          .merge(mapped_query(PAGINATION_PARAMS, options))
          .merge(date_query(options.fetch(:created_at, {})))
          .merge(order_query(options[:order]))
      end

      def mapped_query(map, options)
        map.each_with_object({}) do |(key, param), query|
          value = options[key]
          next if value.nil?

          query[param] = value
        end
      end

      def date_query(created_at)
        DATE_FILTERS.each_with_object({}) do |filter, query|
          value = created_at[filter]
          next if value.nil?

          query["createdAt[#{filter}]"] = value
        end
      end

      def order_query(order)
        return {} if order.nil?

        { 'order[createdAt]' => order }
      end

      def list_headers(options)
        headers = { 'Accept' => LD_JSON }
        return headers unless options[:cursor]

        headers.merge 'X-Pagination-Style' => 'cursor'
      end
    end
  end
end
