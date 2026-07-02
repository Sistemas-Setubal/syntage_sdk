require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Entities do
  subject(:entities) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, patch: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the entities path' do
      entities.list

      expect(client).to have_received(:get).with('entities', anything)
    end

    it 'requests the JSON-LD representation' do
      entities.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      entities.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'maps rfc to the taxpayer id param' do
      entities.list rfc: 'XAXX010101000'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.id' => 'XAXX010101000')))
    end

    it 'maps name to the taxpayer name param' do
      entities.list name: 'Pedro Infante'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.name' => 'Pedro Infante')))
    end

    it 'maps person_type to the taxpayer person type param' do
      entities.list person_type: 'legal'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.personType' => 'legal')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      entities.list id_lt: '91106968-…'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => '91106968-…')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      entities.list id_gt: '91106968-…'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => '91106968-…')))
    end

    it 'maps registration_date filters to bracketed params' do
      entities.list registration_date: { after: '2020-01-17' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('taxpayer.registrationDate[after]' => '2020-01-17')))
    end

    it 'maps updated_at filters to bracketed params' do
      entities.list updated_at: { before: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('updatedAt[before]' => '2026-01-01')))
    end

    it 'maps created_at filters to bracketed params' do
      entities.list created_at: { strictly_after: '2026-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_after]' => '2026-01-01')))
    end

    it 'maps order created_at to the bracketed camelCase param' do
      entities.list order: { created_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'desc')))
    end

    it 'maps order updated_at to the bracketed camelCase param' do
      entities.list order: { updated_at: 'asc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[updatedAt]' => 'asc')))
    end

    it 'maps items_per_page to the camelCase param' do
      entities.list items_per_page: 25

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('itemsPerPage' => 25)))
    end

    it 'ignores unknown filters' do
      entities.list bogus: 'nope'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(entities.list).to be(response)
    end
  end

  describe '#retrieve' do
    let(:id) { 'a1fbecf9-0330-4821-886c-7d45da9c29f4' }

    it 'gets the entity path with the id' do
      entities.retrieve id

      expect(client).to have_received(:get).with("entities/#{id}", anything)
    end

    it 'requests the JSON-LD representation' do
      entities.retrieve id

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(entities.retrieve(id)).to be(response)
    end
  end

  describe '#create' do
    it 'posts to the entities path' do
      entities.create name: 'Acme', type: 'company'

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'entities'))
    end

    it 'sends the required name and type' do
      entities.create name: 'Acme', type: 'company'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(name: 'Acme', type: 'company')))
    end

    it 'includes the rfc when given' do
      entities.create name: 'Acme', type: 'company', rfc: 'XAXX010101000'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(rfc: 'XAXX010101000')))
    end

    it 'omits the rfc when not given' do
      entities.create name: 'Acme', type: 'company'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:rfc)))
    end

    it 'includes the datasources when given' do
      entities.create name: 'Acme', type: 'company', datasources: [{ name: 'mx_sat' }]

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(datasources: [{ name: 'mx_sat' }])))
    end

    it 'omits the datasources when not given' do
      entities.create name: 'Acme', type: 'company'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:datasources)))
    end

    it 'returns the client response' do
      expect(entities.create(name: 'Acme', type: 'company')).to be(response)
    end
  end

  describe '#update' do
    it 'patches the entity path with the id' do
      entities.update 'ent_1', name: 'Syntage'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(path: 'entities/ent_1'))
    end

    it 'includes the name when given' do
      entities.update 'ent_1', name: 'Syntage'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_including(name: 'Syntage')))
    end

    it 'includes the tags when given' do
      entities.update 'ent_1', tags: ['/entity-tags/abc']

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_including(tags: ['/entity-tags/abc'])))
    end

    it 'omits fields that are not given' do
      entities.update 'ent_1', name: 'Syntage'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_excluding(:tags)))
    end

    it 'drops unknown fields' do
      entities.update 'ent_1', name: 'Syntage', type: 'person'

      expect(client).to have_received(:patch)
        .with(an_object_having_attributes(body: hash_excluding(:type)))
    end

    it 'returns the client response' do
      expect(entities.update('ent_1', name: 'Syntage')).to be(response)
    end
  end
end
