# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Products < EntityScopedResource
        include Options

        def sold(**options)
          client.get path('products-and-services-sold'), query: options_query(options, :from, :to)
        end

        def bought(**options)
          client.get path('products-and-services-bought'), query: options_query(options, :from, :to)
        end

        private

        def path(segment)
          "entities/#{entity_id}/insights/#{segment}"
        end
      end
    end
  end
end
