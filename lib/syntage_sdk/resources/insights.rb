# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights < EntityScopedResource
      include Options

      BASE = 'insights'

      def metrics
        Metrics.new entity_id, client
      end

      def financial_ratios(**options)
        client.get path('financial-ratios'), query: options_query(options, :from, :to)
      end

      def trial_balance(**options)
        client.get path('trial-balance'), query: options_query(options, :from, :to, :periodicity)
      end

      def cash_flow_stats(**options)
        client.get path('cash-flow-stats'), query: options_query(options, :from, :to, :periodicity, :type)
      end

      def accounts_payable(**options)
        client.get path('accounts-payable'), query: options_query(options, :from, :to, :periodicity)
      end

      def accounts_receivable(**options)
        client.get path('accounts-receivable'), query: options_query(options, :from, :to, :periodicity)
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
