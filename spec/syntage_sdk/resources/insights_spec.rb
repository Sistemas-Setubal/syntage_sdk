require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Insights do
  subject(:insights) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client }

  describe '#metrics' do
    it 'returns a metrics resource' do
      expect(insights.metrics).to be_a(SyntageSdk::Resources::Insights::Metrics)
    end
  end
end
