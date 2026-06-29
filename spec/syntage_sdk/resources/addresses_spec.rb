require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Addresses do
  subject(:addresses) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#lookup' do
    it 'gets the addresses path with the given postal code' do
      addresses.lookup '06600'

      expect(client).to have_received(:get).with('datasources/mx/addresses/06600')
    end

    it 'returns the client response' do
      expect(addresses.lookup('06600')).to be(response)
    end
  end
end
