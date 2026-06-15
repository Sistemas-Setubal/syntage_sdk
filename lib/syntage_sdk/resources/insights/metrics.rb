# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Metrics < BaseResource
        BASE = 'insights/metrics'
        FORMAT_HEADER = 'X-Insight-Format'

        def initialize(entity_id, client = SyntageSdk.client)
          super(client)
          @entity_id = entity_id
        end

        def balance_sheet(format: nil, from: nil, to: nil)
          client.get path('balance-sheet'), query: date_range(from, to), headers: insight_format(format)
        end

        private

        attr_reader :entity_id

        def path(segment)
          "entities/#{entity_id}/#{BASE}/#{segment}"
        end

        def date_range(from, to)
          { 'options[from]' => from, 'options[to]' => to }.compact
        end

        def insight_format(format)
          return unless format

          { FORMAT_HEADER => format.to_s }
        end
      end
    end
  end
end
