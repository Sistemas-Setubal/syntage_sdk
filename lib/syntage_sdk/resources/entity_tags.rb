# frozen_string_literal: true

module SyntageSdk
  module Resources
    class EntityTags < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(**options)
        list_collection 'entity-tags', LIST, options
      end

      def list_for_entity(entity_id:, **options)
        list_collection "entities/#{entity_id}/tags", LIST, options
      end

      def retrieve(id)
        retrieve_resource "entity-tags/#{id}"
      end

      def create(name:)
        client.post WriteRequest.new(path: 'entity-tags', body: { name: name })
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
