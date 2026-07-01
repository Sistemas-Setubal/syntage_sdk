# frozen_string_literal: true

module SyntageSdk
  module Resources
    class EntityScopedResource
      def initialize(entity_id, client = SyntageSdk.client)
        @entity_id = entity_id
        @client = client
      end

      private

      attr_reader :entity_id, :client
    end
  end
end
