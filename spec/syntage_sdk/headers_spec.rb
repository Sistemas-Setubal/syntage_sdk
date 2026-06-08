require 'syntage_sdk'

RSpec.describe SyntageSdk::Headers do
  it 'looks up keys case-insensitively' do
    headers = described_class.new 'X-Request-ID' => 'abc'

    expect(headers.get('x-request-id')).to eq('abc')
  end

  it 'matches regardless of how the lookup name is cased' do
    headers = described_class.new 'x-request-id' => 'abc'

    expect(headers.get('X-Request-ID')).to eq('abc')
  end

  it 'returns nil for an absent header' do
    headers = described_class.new 'X-Request-ID' => 'abc'

    expect(headers.get('X-Missing')).to be_nil
  end

  it 'tolerates nil raw headers' do
    headers = described_class.new nil

    expect(headers.get('X-Request-ID')).to be_nil
  end
end
