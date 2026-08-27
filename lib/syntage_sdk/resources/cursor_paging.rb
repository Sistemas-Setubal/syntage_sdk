# frozen_string_literal: true

module SyntageSdk
  module Resources
    module CursorPaging
      PAGE_SIZE = 200

      private

      def each_page(resource, date_filter, **filters)
        cursor = nil

        loop do
          members = fetch_page resource, page_options(date_filter, cursor, filters)
          break if members.empty?

          members.each { |member| yield member }
          break if members.size < PAGE_SIZE

          cursor = members.last['id']
        end
      end

      def fetch_page(resource, options)
        resource.list(**options).body['hydra:member'] || []
      end

      def page_options(date_filter, cursor, filters)
        options = { entity_id: entity_id, items_per_page: PAGE_SIZE, cursor: true, issued_at: date_filter }
        options[:id_lt] = cursor if cursor

        options.merge filters
      end
    end
  end
end
