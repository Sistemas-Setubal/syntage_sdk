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

      NUMERIC_OPERATORS = %i[gt gte lt lte between].freeze

      CREATED_AT = 'createdAt'

      private

      def list_collection(path, config, options)
        client.get path, query: list_query(config, options), headers: list_headers(options)
      end

      def list_query(config, options)
        date_fields = config.dates.merge created_at: CREATED_AT

        mapped_query(config.filters, options)
          .merge(mapped_query(PAGINATION_PARAMS, options))
          .merge(bracketed_query(date_fields, DATE_FILTERS, options))
          .merge(bracketed_query(config.numeric, NUMERIC_OPERATORS, options))
          .merge order_query(config.orders, options[:order])
      end

      def mapped_query(map, options)
        map.each_with_object({}) do |(key, param), query|
          value = options[key]
          next if value.nil?

          query[param] = value
        end
      end

      def bracketed_query(fields, operators, options)
        fields.each_with_object({}) do |(key, param), query|
          query.merge! field_operators(param, operators, options[key])
        end
      end

      def field_operators(param, operators, operations)
        return {} if operations.nil?

        operations.slice(*operators).compact.each_with_object({}) do |(operator, value), query|
          query["#{param}[#{operator}]"] = value
        end
      end

      def order_query(fields, order)
        return {} if order.nil?
        return { "order[#{CREATED_AT}]" => order } unless order.is_a? Hash

        order.slice(*fields.keys).compact.each_with_object({}) do |(key, value), query|
          query["order[#{fields[key]}]"] = value
        end
      end

      def list_headers(options)
        headers = { 'Accept' => LD_JSON }
        return headers unless options[:cursor]

        headers.merge 'X-Pagination-Style' => 'cursor'
      end
    end
  end
end
