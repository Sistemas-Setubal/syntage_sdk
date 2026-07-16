require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights do
  subject(:insights) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#metrics' do
    it 'returns a metrics resource' do
      expect(insights.metrics).to be_a(SyntageSdk::Resources::Insights::Metrics)
    end
  end

  describe '#accounting' do
    it 'returns an accounting resource' do
      expect(insights.accounting).to be_a(SyntageSdk::Resources::Insights::Accounting)
    end
  end

  describe '#concentration' do
    it 'returns a concentration resource' do
      expect(insights.concentration).to be_a(SyntageSdk::Resources::Insights::Concentration)
    end
  end

  describe '#sales_revenue' do
    it 'gets the entity-scoped sales-revenue path' do
      insights.sales_revenue

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/sales-revenue', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.sales_revenue

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.sales_revenue from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'maps to to the options[to] query param' do
      insights.sales_revenue to: '2024-12-31T23:59:59Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[to]' => '2024-12-31T23:59:59Z')))
    end

    it 'omits date filters that are not given' do
      insights.sales_revenue from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.sales_revenue).to be(response)
    end
  end

  describe '#products' do
    it 'returns a products resource' do
      expect(insights.products).to be_a(SyntageSdk::Resources::Insights::Products)
    end
  end

  describe '#expenditures' do
    it 'gets the entity-scoped expenditures path' do
      insights.expenditures

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/expenditures', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.expenditures

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.expenditures from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2022-01-01T00:00:00Z')))
    end

    it 'maps to to the options[to] query param' do
      insights.expenditures to: '2024-12-31T23:59:59Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[to]' => '2024-12-31T23:59:59Z')))
    end

    it 'omits date filters that are not given' do
      insights.expenditures from: '2022-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.expenditures).to be(response)
    end
  end

  describe '#financial_institutions' do
    it 'gets the entity-scoped financial-institutions path' do
      insights.financial_institutions

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/financial-institutions', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.financial_institutions

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.financial_institutions from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.financial_institutions from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.financial_institutions).to be(response)
    end
  end

  describe '#employees' do
    it 'gets the entity-scoped employees path' do
      insights.employees

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/employees', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.employees

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.employees from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.employees from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'maps periodicity to the options[periodicity] query param' do
      insights.employees periodicity: 'monthly'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[periodicity]' => 'monthly')))
    end

    it 'returns the client response' do
      expect(insights.employees).to be(response)
    end
  end

  describe '#rpc_shareholders' do
    it 'gets the entity-scoped rpc-shareholders path' do
      insights.rpc_shareholders

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/rpc-shareholders', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.rpc_shareholders

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.rpc_shareholders from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.rpc_shareholders from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.rpc_shareholders).to be(response)
    end
  end

  describe '#government_customers' do
    it 'gets the entity-scoped government-customers path' do
      insights.government_customers

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/government-customers', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.government_customers

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.government_customers from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.government_customers from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.government_customers).to be(response)
    end
  end

  describe '#invoicing_blacklist' do
    it 'gets the entity-scoped invoicing-blacklist path' do
      insights.invoicing_blacklist

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/invoicing-blacklist', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.invoicing_blacklist

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.invoicing_blacklist from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.invoicing_blacklist from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.invoicing_blacklist).to be(response)
    end
  end

  describe '#risks' do
    it 'gets the entity-scoped risks path' do
      insights.risks

      expect(client).to have_received(:get)
        .with('entities/ent_123/insights/risks', anything)
    end

    it 'sends an empty query when no filters are given' do
      insights.risks

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps from to the options[from] query param' do
      insights.risks from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('options[from]' => '2024-01-01T00:00:00Z')))
    end

    it 'omits date filters that are not given' do
      insights.risks from: '2024-01-01T00:00:00Z'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_excluding('options[to]')))
    end

    it 'returns the client response' do
      expect(insights.risks).to be(response)
    end
  end

  describe '#summary' do
    it 'gets the entity-scoped summary path' do
      insights.summary

      expect(client).to have_received(:get).with('entities/ent_123/insights/summary')
    end

    it 'returns the client response' do
      expect(insights.summary).to be(response)
    end
  end
end
