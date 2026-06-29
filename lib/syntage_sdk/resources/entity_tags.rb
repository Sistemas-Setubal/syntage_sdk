# frozen_string_literal: true

module SyntageSdk
  module Resources
    class EntityTags < BaseResource
      include Listable
      include Retrievable

      LIST = ListConfig.new(filters: {}).freeze

      def list(**options)
        list_collection 'entity-tags', LIST, options
      end

      def retrieve(id)
        retrieve_resource "entity-tags/#{id}"
      end

      def create(entity_id:, name:)
        client.post WriteRequest.new(path: 'entity-tags', body: { entityId: entity_id, name: name })
      end

      def update(id, name:)
        client.patch WriteRequest.new(path: "entity-tags/#{id}", body: { name: name })
      end

      def destroy(id)
        client.delete "entity-tags/#{id}"
      end
    end
  end
end
