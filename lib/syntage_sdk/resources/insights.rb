# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights < BaseResource
      include DateRange

      BASE = 'insights'

      def initialize(entity_id, client = SyntageSdk.client)
        super(client)
        @entity_id = entity_id
      end

      def metrics
        Metrics.new entity_id, client
      end

      def financial_ratios(**options)
        client.get path('financial-ratios'), query: date_range(options)
      end

      private

      attr_reader :entity_id

      def path(segment)
        "entities/#{entity_id}/#{BASE}/#{segment}"
      end
    end
  end
end
