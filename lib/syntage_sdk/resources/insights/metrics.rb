# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Metrics < BaseResource
        include Options

        BASE = 'insights/metrics'
        FORMAT_HEADER = 'X-Insight-Format'

        def initialize(entity_id, client = SyntageSdk.client)
          super(client)
          @entity_id = entity_id
        end

        def balance_sheet(**options)
          statement 'balance-sheet', options
        end

        def income_statement(**options)
          statement 'income-statement', options
        end

        def scores
          client.get path('scores')
        end

        private

        attr_reader :entity_id

        def statement(segment, options)
          client.get path(segment), query: options_query(options, :from, :to), headers: insight_format(options)
        end

        def path(segment)
          "entities/#{entity_id}/#{BASE}/#{segment}"
        end

        def insight_format(options)
          format = options[:format]
          return unless format

          { FORMAT_HEADER => format.to_s }
        end
      end
    end
  end
end
