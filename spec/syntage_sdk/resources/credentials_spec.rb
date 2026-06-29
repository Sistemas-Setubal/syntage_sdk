require 'syntage_sdk'
require 'base64'

RSpec.describe SyntageSdk::Resources::Credentials do
  subject(:credentials) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, post: response }
  let(:response) { instance_double SyntageSdk::Response }

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
end
