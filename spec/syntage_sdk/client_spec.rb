require 'syntage_sdk'

RSpec.describe SyntageSdk::Client do
  subject(:client) { described_class.new configuration }

  let :configuration do
    config = SyntageSdk::Configuration.new
    config.api_key = 'sk_test_123'
    config.base_url = 'https://api.example.com'
    config
  end

  def http_response(status, body: nil, headers: {})
    instance_double \
      HTTParty::Response, code: status, parsed_response: body, headers: headers
  end

  def attempt(path = 'taxpayers')
    client.get path
  rescue SyntageSdk::Error
    nil
  end

  before { allow(client).to receive(:sleep) }

  describe 'on a successful response' do
    let :response do
      http_response 200,
                    body: { 'id' => 'tp_1' },
                    headers: { 'X-Request-ID' => 'req-1', 'X-RateLimit-Remaining' => '59' }
    end

    before { allow(HTTParty).to receive(:get).and_return(response) }

    it 'returns a wrapped response with the parsed body' do
      expect(client.get('taxpayers').body).to eq('id' => 'tp_1')
    end

    it 'exposes the request id from the headers' do
      expect(client.get('taxpayers').request_id).to eq('req-1')
    end

    it 'exposes the rate limit from the headers' do
      expect(client.get('taxpayers').rate_limit.remaining).to eq(59)
    end

    it 'builds the full URL from the base URL and path' do
      client.get '/taxpayers'

      expect(HTTParty).to have_received(:get).with('https://api.example.com/taxpayers', anything)
    end

    it 'sends the configured authentication headers' do
      client.get 'taxpayers'

      expect(HTTParty).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-API-Key' => 'sk_test_123')))
    end

    it 'forwards query parameters' do
      client.get 'taxpayers', query: { page: 2 }

      expect(HTTParty).to have_received(:get)
        .with(anything, hash_including(query: { page: 2 }))
    end

    it 'merges per-request headers over the configured ones' do
      client.get 'events', headers: { 'Accept' => 'application/ld+json' }

      expect(HTTParty).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'keeps the configured headers when merging per-request ones' do
      client.get 'events', headers: { 'Accept' => 'application/ld+json' }

      expect(HTTParty).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('X-API-Key' => 'sk_test_123')))
    end

    it 'parses JSON requests with the JSON parser' do
      client.get 'events'

      expect(HTTParty).to have_received(:get).with(anything, hash_including(format: :json))
    end

    it 'parses JSON-LD requests with the JSON parser' do
      client.get 'events', headers: { 'Accept' => 'application/ld+json' }

      expect(HTTParty).to have_received(:get).with(anything, hash_including(format: :json))
    end

    it 'returns raw bodies for non-JSON representations' do
      client.get 'invoices/abc/cfdi', headers: { 'Accept' => 'application/pdf' }

      expect(HTTParty).to have_received(:get).with(anything, hash_including(format: :plain))
    end
  end

  describe 'when sending a body' do
    let(:response) { http_response 201, body: { 'id' => 'tp_1' } }

    before { allow(HTTParty).to receive(:post).and_return(response) }

    it 'serializes the body as JSON' do
      client.post 'taxpayers', body: { rfc: 'XAXX010101000' }

      expect(HTTParty).to have_received(:post)
        .with(anything, hash_including(body: '{"rfc":"XAXX010101000"}'))
    end
  end

  describe 'when deleting a resource' do
    let(:response) { http_response 204 }

    before { allow(HTTParty).to receive(:delete).and_return(response) }

    it 'calls HTTParty.delete with the correct URL' do
      client.delete 'authorizations/abc-123'

      expect(HTTParty).to have_received(:delete)
        .with('https://api.example.com/authorizations/abc-123', anything)
    end

    it 'returns a wrapped response' do
      expect(client.delete('authorizations/abc-123')).to be_a(SyntageSdk::Response)
    end
  end

  describe 'when the API responds with 401' do
    before do
      allow(HTTParty).to receive(:get)
        .and_return(http_response(401, headers: { 'X-Request-ID' => 'req-401' }))
    end

    it 'raises an AuthenticationError' do
      expect { client.get('taxpayers') }.to raise_error(SyntageSdk::AuthenticationError)
    end

    it 'exposes the request id on the error' do
      expect { client.get('taxpayers') }
        .to raise_error(an_object_having_attributes(request_id: 'req-401'))
    end

    it 'does not retry' do
      attempt

      expect(HTTParty).to have_received(:get).once
    end
  end

  describe 'when the API responds with 429' do
    let :rate_limited do
      http_response 429, headers: { 'X-RateLimit-Remaining' => '0', 'X-RateLimit-Reset' => '1606678044' }
    end

    describe 'and it keeps failing' do
      before { allow(HTTParty).to receive(:get).and_return(rate_limited) }

      it 'raises a RateLimitError after exhausting retries' do
        expect { client.get('taxpayers') }.to raise_error(SyntageSdk::RateLimitError)
      end

      it 'retries up to max_retries times' do
        attempt

        expect(HTTParty).to have_received(:get).exactly(3).times
      end

      it 'backs off exponentially between attempts' do
        delays = []
        allow(client).to receive(:sleep) { |seconds| delays << seconds }

        attempt

        expect(delays).to eq([0.5, 1.0])
      end

      it 'exposes the rate limit on the error' do
        expect { client.get('taxpayers') }
          .to raise_error(an_object_having_attributes(rate_limit: an_object_having_attributes(remaining: 0)))
      end
    end

    describe 'and it later succeeds' do
      before do
        allow(HTTParty).to receive(:get)
          .and_return(rate_limited, http_response(200, body: { 'ok' => true }))
      end

      it 'returns the successful response' do
        expect(client.get('taxpayers').body).to eq('ok' => true)
      end

      it 'stops retrying once it succeeds' do
        client.get 'taxpayers'

        expect(HTTParty).to have_received(:get).twice
      end
    end
  end

  describe 'when the API responds with 400' do
    before do
      allow(HTTParty).to receive(:post)
        .and_return(http_response(400, body: { 'message' => 'name is required' }))
    end

    it 'raises a ValidationError' do
      expect { client.post('entities', body: {}) }.to raise_error(SyntageSdk::ValidationError)
    end

    it 'includes the API detail in the message' do
      expect { client.post('entities', body: {}) }.to raise_error(/name is required/)
    end

    it 'exposes the response body on the error' do
      expect { client.post('entities', body: {}) }
        .to raise_error(an_object_having_attributes(body: { 'message' => 'name is required' }))
    end
  end

  describe 'when the API responds with 403' do
    before do
      allow(HTTParty).to receive(:post)
        .and_return(http_response(403, body: { 'message' => 'Forbidden' }))
    end

    it 'raises a ForbiddenError' do
      expect { client.post('entities', body: {}) }.to raise_error(SyntageSdk::ForbiddenError)
    end
  end

  describe 'when the API responds with another error status' do
    before { allow(HTTParty).to receive(:get).and_return(http_response(500)) }

    it 'raises a generic ApiError' do
      expect { client.get('taxpayers') }.to raise_error(SyntageSdk::ApiError, /500/)
    end
  end
end
