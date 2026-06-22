require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::SyntageScore do
  subject(:syntage_score) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, post: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#calculate' do
    it 'posts to the entity-scoped score calculate path' do
      syntage_score.calculate

      expect(client).to have_received(:post)
        .with('entities/ent_123/datasources/syntage/score/calculate', body: {})
    end

    it 'returns the client response' do
      expect(syntage_score.calculate).to be(response)
    end
  end
end
