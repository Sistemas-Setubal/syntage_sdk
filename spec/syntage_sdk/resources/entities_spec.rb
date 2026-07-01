require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::Entities do
  subject(:entities) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, post: response, patch: response }
  let(:response) { instance_double SyntageSdk::Response }

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
