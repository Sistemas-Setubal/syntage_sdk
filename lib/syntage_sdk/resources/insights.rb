# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights < BaseResource
      def initialize(entity_id, client = SyntageSdk.client)
        super(client)
        @entity_id = entity_id
      end

      def metrics
        Metrics.new entity_id, client
      end

      private

      attr_reader :entity_id
    end
  end
end
