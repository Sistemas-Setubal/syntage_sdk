# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Reports < BaseResource
      include Listable
      include Retrievable

      PATH = 'reports'

      LIST = ListConfig.new(filters: {}, orders: { created_at: 'createdAt' }).freeze

      FIELDS = %i[name insights organizational].freeze

      REQUIRED_FIELDS = %i[name insights].freeze

      DEFAULTS = { organizational: false }.freeze

      def list(**options)
        list_collection PATH, LIST, options
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def create(**options)
        client.post WriteRequest.new(path: PATH, body: body(options))
      end

      def update(id, **options)
        client.put WriteRequest.new(path: "#{PATH}/#{id}", body: body(options))
      end

      def destroy(id)
        client.delete "#{PATH}/#{id}"
      end

      private

      def body(options)
        missing = REQUIRED_FIELDS - options.keys
        raise ArgumentError, "missing keyword: #{missing.join ', '}" if missing.any?

        DEFAULTS.merge options.slice(*FIELDS)
      end
    end
  end
end
