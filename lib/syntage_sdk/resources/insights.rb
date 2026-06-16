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

      def cash_flow_stats(**options)
        client.get path('cash-flow-stats'), query: options_query(options, :from, :to, :periodicity, :type)
      end

      def accounts_payable(**options)
        client.get path('accounts-payable'), query: options_query(options, :from, :to, :periodicity)
      end

      def accounts_receivable(**options)
        client.get path('accounts-receivable'), query: options_query(options, :from, :to, :periodicity)
      end

      def invoicing_concentration(type:, **options)
        client.get path('invoicing-concentration'), query: options_query(options.merge(type:), :type, :from, :to)
      end

      def sales_revenue(**options)
        client.get path('sales-revenue'), query: options_query(options, :from, :to)
      end

      def products_and_services_sold(**options)
        client.get path('products-and-services-sold'), query: options_query(options, :from, :to)
      end

      def products_and_services_bought(**options)
        client.get path('products-and-services-bought'), query: options_query(options, :from, :to)
      end

      def expenditures(**options)
        client.get path('expenditures'), query: options_query(options, :from, :to)
      end

      def customer_concentration(**options)
        client.get path('customer-concentration'), query: options_query(options, :from, :to)
      end

      def supplier_concentration(**options)
        client.get path('supplier-concentration'), query: options_query(options, :from, :to)
      end

      def summary
        client.get path('summary')
      end

      private

      attr_reader :entity_id

      def path(segment)
        "entities/#{entity_id}/#{BASE}/#{segment}"
      end
    end
  end
end
