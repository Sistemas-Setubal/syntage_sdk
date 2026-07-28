require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Reports do
  subject(:reports) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the reports path' do
      reports.list

      expect(client).to have_received(:get).with('reports', anything)
    end

    it 'requests the JSON-LD representation' do
      reports.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no options are given' do
      reports.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'sends itemsPerPage when given' do
      reports.list items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 50)))
    end

    it 'sends page when given' do
      reports.list page: 2

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 2)))
    end

    it 'maps a plain order to the creation date order' do
      reports.list order: :desc

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => :desc)))
    end

    it 'maps a named order to the creation date order' do
      reports.list order: { created_at: :asc }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => :asc)))
    end

    it 'sends creation date filters' do
      reports.list created_at: { after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[after]' => '2026-01-01')))
    end

    it 'requests cursor pagination when asked' do
      reports.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'returns the client response' do
      expect(reports.list).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the reports path with the id' do
      reports.retrieve 'rep_1'

      expect(client).to have_received(:get).with('reports/rep_1', anything)
    end

    it 'requests the JSON-LD representation' do
      reports.retrieve 'rep_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(reports.retrieve('rep_1')).to be(response)
    end
  end
end
