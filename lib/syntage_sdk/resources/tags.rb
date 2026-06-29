# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Tags < BaseResource
      include Listable

      LIST = ListConfig.new(filters: {}).freeze

      def list(**options)
        list_collection 'tags', LIST, options
      end

      def create(name:, resource_type:, resource_id: nil)
        body = { name: name, resourceType: resource_type, resourceId: resource_id }.compact
        client.post WriteRequest.new(path: 'tags', body: body)
      end

      def update(id, name:)
        client.patch WriteRequest.new(path: "tags/#{id}", body: { name: name })
      end

      def destroy(id)
        client.delete "tags/#{id}"
      end
    end
  end
end
