# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Rug < EntityScopedResource
      include Listable
      include Retrievable

      LIST = ListConfig.new(filters: {}).freeze

      def guarantees(**options)
        list_collection "entities/#{entity_id}/datasources/rug/garantias", LIST, options
      end

      def guarantee(id)
        retrieve_resource "datasources/rug/garantias/#{id}"
      end

      def operations(**options)
        list_collection "entities/#{entity_id}/datasources/rug/operaciones", LIST, options
      end

      def operation(id)
        retrieve_resource "datasources/rug/operaciones/#{id}"
      end
    end
  end
end
