# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Rug < EntityScopedResource
      include Listable

      LIST = ListConfig.new(filters: {}).freeze

      def guarantees(**options)
        list_collection "entities/#{entity_id}/datasources/rug/garantias", LIST, options
      end
    end
  end
end
