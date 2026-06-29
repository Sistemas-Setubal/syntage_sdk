require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::SatCertificates do
  subject(:sat_certificates) { described_class.new 'ent_123', client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entity-scoped sat/certificados path' do
      sat_certificates.list

      expect(client).to have_received(:get)
        .with('entities/ent_123/datasources/mx/sat/certificados', anything)
    end

    it 'requests the JSON-LD representation' do
      sat_certificates.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      sat_certificates.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the type filter' do
      sat_certificates.list type: 'efirma'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'efirma')))
    end

    it 'maps serial_number to the camelCase param' do
      sat_certificates.list serial_number: '00001000000516152485'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('serialNumber' => '00001000000516152485')))
    end

    it 'maps valid_from date filter to the bracketed camelCase param' do
      sat_certificates.list valid_from: { after: '2020-01-01T00:00:00+00:00' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('validFrom[after]' => '2020-01-01T00:00:00+00:00')))
    end

    it 'maps valid_to date filter to the bracketed camelCase param' do
      sat_certificates.list valid_to: { before: '2030-01-01T00:00:00+00:00' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('validTo[before]' => '2030-01-01T00:00:00+00:00')))
    end

    it 'maps order valid_from to the bracketed camelCase param' do
      sat_certificates.list order: { valid_from: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[validFrom]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      sat_certificates.list items_per_page: 10

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 10)))
    end

    it 'enables cursor pagination when cursor: true' do
      sat_certificates.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'returns the client response' do
      expect(sat_certificates.list).to be(response)
    end
  end

  describe '#check_expiry' do
    before { allow(Date).to receive(:today).and_return(Date.new(2025, 1, 1)) }

    it 'sends validTo[after] set to today' do
      sat_certificates.check_expiry

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('validTo[after]' => '2025-01-01')))
    end

    it 'sends validTo[strictly_before] set to 30 days from today by default' do
      sat_certificates.check_expiry

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('validTo[strictly_before]' => '2025-01-31')))
    end

    it 'accepts a custom threshold_days' do
      sat_certificates.check_expiry threshold_days: 7

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('validTo[strictly_before]' => '2025-01-08')))
    end

    it 'returns the client response' do
      expect(sat_certificates.check_expiry).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the global sat/certificados path with id' do
      sat_certificates.retrieve 'cert_123'

      expect(client).to have_received(:get)
        .with('datasources/mx/sat/certificados/cert_123', anything)
    end

    it 'requests the JSON-LD representation' do
      sat_certificates.retrieve 'cert_123'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(sat_certificates.retrieve('cert_123')).to be(response)
    end
  end
end
