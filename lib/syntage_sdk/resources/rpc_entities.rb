# frozen_string_literal: true

module SyntageSdk
  module Resources
    class RpcEntities < EntityScopedResource
      include Listable
      include Retrievable

      LIST = ListConfig.new(filters: {}).freeze

      def list(**options)
        list_collection "entities/#{entity_id}/datasources/rpc/entidades", LIST, options
      end

      def retrieve(id)
        retrieve_resource "datasources/rpc/entidades/#{id}"
      end
    end
  end
end
