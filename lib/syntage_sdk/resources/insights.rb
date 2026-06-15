# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights < BaseResource
      include Options

      BASE = 'insights'

      def initialize(entity_id, client = SyntageSdk.client)
        super(client)
        @entity_id = entity_id
      end

      def metrics
        Metrics.new entity_id, client
      end

      def financial_ratios(**options)
        client.get path('financial-ratios'), query: options_query(options, :from, :to)
      end

      def trial_balance(**options)
        client.get path('trial-balance'), query: options_query(options, :from, :to, :periodicity)
      end

      private

      attr_reader :entity_id

      def path(segment)
        "entities/#{entity_id}/#{BASE}/#{segment}"
      end
    end
  end
end
