# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights < EntityScopedResource
      include Options

      BASE = 'insights'

      def metrics
        Metrics.new entity_id, client
      end

      def accounting
        Accounting.new entity_id, client
      end

      def concentration
        Concentration.new entity_id, client
      end

      def products
        Products.new entity_id, client
      end

      def sales_revenue(**options)
        client.get path('sales-revenue'), query: options_query(options, :from, :to)
      end

      def expenditures(**options)
        client.get path('expenditures'), query: options_query(options, :from, :to)
      end

      def financial_institutions(**options)
        client.get path('financial-institutions'), query: options_query(options, :from, :to)
      end

      def employees(**options)
        client.get path('employees'), query: options_query(options, :from, :to)
      end

      def rpc_shareholders(**options)
        client.get path('rpc-shareholders'), query: options_query(options, :from, :to)
      end

      def government_customers(**options)
        client.get path('government-customers'), query: options_query(options, :from, :to)
      end

      def invoicing_blacklist(**options)
        client.get path('invoicing-blacklist'), query: options_query(options, :from, :to)
      end

      def risks(**options)
        client.get path('risks'), query: options_query(options, :from, :to)
      end

      def summary
        client.get path('summary')
      end

      private

      def path(segment)
        "entities/#{entity_id}/#{BASE}/#{segment}"
      end
    end
  end
end
