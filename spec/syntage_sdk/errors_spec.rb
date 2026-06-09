require 'syntage_sdk'

RSpec.describe 'SyntageSdk errors' do
  let :metadata do
    SyntageSdk::ResponseMetadata.from_headers \
      'X-Request-ID' => 'req-123',
      'X-RateLimit-Limit' => '60',
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => '1606678044'
  end

  describe SyntageSdk::ApiError do
    it 'exposes the request id from its metadata' do
      error = described_class.new 'boom', metadata: metadata

      expect(error.request_id).to eq('req-123')
    end

    it 'keeps the message' do
      error = described_class.new 'boom', metadata: metadata

      expect(error.message).to eq('boom')
    end

    it 'has no request id without metadata' do
      expect(described_class.new('boom').request_id).to be_nil
    end
  end

  describe SyntageSdk::ForbiddenError do
    it 'is an ApiError' do
      expect(described_class.new('forbidden')).to be_a(SyntageSdk::ApiError)
    end
  end

  describe SyntageSdk::ValidationError do
    it 'is an ApiError' do
      expect(described_class.new('bad request')).to be_a(SyntageSdk::ApiError)
    end

    it 'exposes the response body so the caller sees what failed' do
      error = described_class.new 'bad request', body: { 'message' => 'name is required' }

      expect(error.body).to eq('message' => 'name is required')
    end
  end

  describe SyntageSdk::RateLimitError do
    subject(:error) { described_class.new 'Too Many Requests', metadata: metadata }

    it 'is an ApiError' do
      expect(error).to be_a(SyntageSdk::ApiError)
    end

    it 'exposes the rate limit so the caller can back off' do
      expect(error.rate_limit).to have_attributes(remaining: 0, limit: 60)
    end

    it 'still exposes the request id' do
      expect(error.request_id).to eq('req-123')
    end

    it 'has no rate limit without metadata' do
      expect(described_class.new('boom').rate_limit).to be_nil
    end
  end
end
