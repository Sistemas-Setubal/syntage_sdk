require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::BaseResource do
  describe 'when no client is given' do
    subject(:resource) { described_class.new }

    it 'falls back to the global client' do
      expect(resource.send(:client)).to be(SyntageSdk.client)
    end
  end

  describe 'when a client is given' do
    subject(:resource) { described_class.new custom_client }

    let(:custom_client) { instance_double SyntageSdk::Client }

    it 'uses the provided client' do
      expect(resource.send(:client)).to be(custom_client)
    end
  end
end
