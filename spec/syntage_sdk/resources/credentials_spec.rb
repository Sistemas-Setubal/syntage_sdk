require 'syntage_sdk'
require 'base64'

RSpec.describe SyntageSdk::Resources::Credentials do
  subject(:credentials) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#list' do
    it 'gets the credentials path' do
      credentials.list

      expect(client).to have_received(:get).with('credentials', anything)
    end

    it 'requests the JSON-LD representation' do
      credentials.list

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'sends an empty query when no filters are given' do
      credentials.list

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'forwards the type filter' do
      credentials.list type: 'ciec'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('type' => 'ciec')))
    end

    it 'forwards the rfc filter' do
      credentials.list rfc: 'PEIC211118IS0'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('rfc' => 'PEIC211118IS0')))
    end

    it 'forwards the status filter' do
      credentials.list status: 'valid'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('status' => 'valid')))
    end

    it 'maps updated_at operators to bracketed params' do
      credentials.list updated_at: { after: '2024-01-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('updatedAt[after]' => '2024-01-01')))
    end

    it 'maps id_lt to the bracketed cursor param' do
      credentials.list id_lt: 'a28083a6'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[lt]' => 'a28083a6')))
    end

    it 'maps id_gt to the bracketed cursor param' do
      credentials.list id_gt: 'a28083a6'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('id[gt]' => 'a28083a6')))
    end

    it 'forwards a field-specific order' do
      credentials.list order: { updated_at: 'desc' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[updatedAt]' => 'desc')))
    end

    it 'requests the cursor pagination style when asked' do
      credentials.list cursor: true

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-Pagination-Style' => 'cursor')))
    end

    it 'maps created_at operators to bracketed params' do
      credentials.list created_at: { strictly_before: '2024-06-01' }

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('createdAt[strictly_before]' => '2024-06-01')))
    end

    it 'forwards the order' do
      credentials.list order: 'desc'

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('order[createdAt]' => 'desc')))
    end

    it 'forwards pagination options' do
      credentials.list page: 2, items_per_page: 50

      expect(client).to have_received(:get)
        .with(anything, hash_including(query: hash_including('page' => 2, 'itemsPerPage' => 50)))
    end

    it 'drops unknown options' do
      credentials.list bogus: 'value'

      expect(client).to have_received(:get).with(anything, hash_including(query: {}))
    end

    it 'returns the client response' do
      expect(credentials.list).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the credential path' do
      credentials.retrieve 'cred_1'

      expect(client).to have_received(:get).with('credentials/cred_1', anything)
    end

    it 'requests the JSON-LD representation' do
      credentials.retrieve 'cred_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(credentials.retrieve('cred_1')).to be(response)
    end
  end

  describe '#create_ciec' do
    it 'posts to the credentials path' do
      credentials.create_ciec rfc: 'PEIC211118IS0', password: 'secret'

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'credentials'))
    end

    it 'sends the ciec type' do
      credentials.create_ciec rfc: 'PEIC211118IS0', password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(type: 'ciec')))
    end

    it 'sends the rfc and password' do
      credentials.create_ciec rfc: 'PEIC211118IS0', password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(rfc: 'PEIC211118IS0', password: 'secret')))
    end

    it 'returns the client response' do
      expect(credentials.create_ciec(rfc: 'PEIC211118IS0', password: 'secret')).to be(response)
    end
  end

  describe '#create_efirma' do
    let(:certificate) { "\x01\x02cert-bytes" }
    let(:private_key) { "\x03\x04key-bytes" }

    it 'posts to the credentials path' do
      credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(client).to have_received(:post).with(an_object_having_attributes(path: 'credentials'))
    end

    it 'sends the efirma type' do
      credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(type: 'efirma')))
    end

    it 'base64-encodes the certificate' do
      credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(certificate: Base64.strict_encode64(certificate))))
    end

    it 'base64-encodes the private_key into the camelCase privateKey field' do
      credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(privateKey: Base64.strict_encode64(private_key))))
    end

    it 'sends the password' do
      credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(password: 'secret')))
    end

    it 'returns the client response' do
      result = credentials.create_efirma certificate: certificate, private_key: private_key, password: 'secret'

      expect(result).to be(response)
    end
  end

  describe '#revalidate' do
    it 'posts to the revalidate path' do
      credentials.revalidate 'cred_1'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(path: 'credentials/cred_1/revalidate'))
    end

    it 'sends an empty body' do
      credentials.revalidate 'cred_1'

      expect(client).to have_received(:post).with(an_object_having_attributes(body: {}))
    end

    it 'returns the client response' do
      expect(credentials.revalidate('cred_1')).to be(response)
    end
  end

  describe '#destroy' do
    it 'deletes the credential path' do
      credentials.destroy 'cred_1'

      expect(client).to have_received(:delete).with('credentials/cred_1')
    end

    it 'returns the client response' do
      expect(credentials.destroy('cred_1')).to be(response)
    end
  end
end
