# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      class Accounting < EntityScopedResource
        include Options

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

        private

        def path(segment)
          "entities/#{entity_id}/insights/#{segment}"
        end
      end
    end
  end
end
