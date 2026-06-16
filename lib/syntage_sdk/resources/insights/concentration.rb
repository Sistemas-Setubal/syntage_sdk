# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Concentration < EntityScopedResource
        include Options

        def invoicing(type:, **options)
          client.get path('invoicing-concentration'), query: options_query(options.merge(type:), :type, :from, :to)
        end

        def customer(**options)
          client.get path('customer-concentration'), query: options_query(options, :from, :to)
        end

        def supplier(**options)
          client.get path('supplier-concentration'), query: options_query(options, :from, :to)
        end

        private

        def path(segment)
          "entities/#{entity_id}/insights/#{segment}"
        end
      end
    end
  end
end
