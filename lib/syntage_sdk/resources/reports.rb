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

      def create(name:, insights:, organizational: false)
        client.post WriteRequest.new(path: PATH, body: body_for(name, insights, organizational))
      end

      def update(id, name:, insights:, organizational: false)
        client.put WriteRequest.new(path: "#{PATH}/#{id}", body: body_for(name, insights, organizational))
      end

      def destroy(id)
        client.delete "#{PATH}/#{id}"
      end

      private

      def body_for(name, insights, organizational)
        { name: name, insights: insights, organizational: organizational }
      end
    end
  end
end
