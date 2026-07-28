# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Reports < BaseResource
      include Listable
      include Retrievable

      PATH = 'reports'

      LIST = ListConfig.new(filters: {}, orders: { created_at: 'createdAt' }).freeze

      def list(**options)
        list_collection PATH, LIST, options
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end
    end
  end
end
