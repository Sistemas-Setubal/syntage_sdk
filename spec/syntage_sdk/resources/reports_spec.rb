require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Reports do
  subject(:reports) { described_class.new client }

  let :client do
    instance_double SyntageSdk::Client, get: response, post: response, put: response, delete: response
  end

  let(:response) { instance_double SyntageSdk::Response }

  let(:insights) { [{ name: 'summary', type: 'insight', insight: 'summary' }] }

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

  describe '#create' do
    it 'posts to the reports path' do
      reports.create name: 'Credit review', insights: insights

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'reports'))
    end

    it 'sends name in the body' do
      reports.create name: 'Credit review', insights: insights

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(name: 'Credit review')))
    end

    it 'sends insights in the body' do
      reports.create name: 'Credit review', insights: insights

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(insights: insights)))
    end

    it 'defaults organizational to false' do
      reports.create name: 'Credit review', insights: insights

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(organizational: false)))
    end

    it 'sends organizational when given' do
      reports.create name: 'Credit review', insights: insights, organizational: true

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(organizational: true)))
    end

    it 'raises when name is missing' do
      expect { reports.create insights: insights }.to raise_error(ArgumentError)
    end

    it 'raises when insights is missing' do
      expect { reports.create name: 'Credit review' }.to raise_error(ArgumentError)
    end

    it 'returns the client response' do
      expect(reports.create(name: 'Credit review', insights: insights)).to be(response)
    end
  end

  describe '#update' do
    it 'puts to the reports path with the given id' do
      reports.update 'rep_1', name: 'Renamed', insights: insights

      expect(client).to have_received(:put).with(an_object_having_attributes(path: 'reports/rep_1'))
    end

    it 'sends name in the body' do
      reports.update 'rep_1', name: 'Renamed', insights: insights

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(name: 'Renamed')))
    end

    it 'sends insights in the body' do
      reports.update 'rep_1', name: 'Renamed', insights: insights

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(insights: insights)))
    end

    it 'defaults organizational to false' do
      reports.update 'rep_1', name: 'Renamed', insights: insights

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(organizational: false)))
    end

    it 'sends organizational when given' do
      reports.update 'rep_1', name: 'Renamed', insights: insights, organizational: true

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(organizational: true)))
    end

    it 'requires insights because the API replaces the whole report' do
      expect { reports.update 'rep_1', name: 'Renamed' }.to raise_error(ArgumentError)
    end

    it 'requires name because the API replaces the whole report' do
      expect { reports.update 'rep_1', insights: insights }.to raise_error(ArgumentError)
    end

    it 'returns the client response' do
      expect(reports.update('rep_1', name: 'Renamed', insights: insights)).to be(response)
    end
  end

  describe '#destroy' do
    it 'deletes the reports path with the given id' do
      reports.destroy 'rep_1'

      expect(client).to have_received(:delete).with('reports/rep_1')
    end

    it 'returns the client response' do
      expect(reports.destroy('rep_1')).to be(response)
    end
  end
end
