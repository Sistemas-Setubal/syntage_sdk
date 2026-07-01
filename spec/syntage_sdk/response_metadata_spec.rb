require 'syntage_sdk'

RSpec.describe SyntageSdk::ResponseMetadata do
  subject :metadata do
    described_class.from_headers \
      'X-Request-ID' => 'f242e9e0-c1ba-4bbe-ba64-4966c702b5d2',
      'X-RateLimit-Limit' => '60',
      'X-RateLimit-Remaining' => '56',
      'X-RateLimit-Reset' => '1606678044'
  end

  it 'exposes the request id for traceability' do
    expect(metadata.request_id).to eq('f242e9e0-c1ba-4bbe-ba64-4966c702b5d2')
  end

  it 'exposes the rate limit details' do
    expect(metadata.rate_limit).to have_attributes(limit: 60, remaining: 56)
  end

  it 'leaves the request id nil when the header is absent' do
    expect(described_class.from_headers({}).request_id).to be_nil
  end
end
