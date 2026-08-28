# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Products < EntityScopedResource
        include Options

        def sold(**options)
          client.get path('products-and-services-sold'), query: ranking_query(options)
        end

        def bought(**options)
          client.get path('products-and-services-bought'), query: ranking_query(options)
        end

        private

        def ranking_query(options)
          options_query options, :from, :to, :limit, :offset
        end

        def path(segment)
          "entities/#{entity_id}/insights/#{segment}"
        end
      end
    end
  end
end
