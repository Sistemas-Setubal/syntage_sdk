require 'syntage_sdk'

RSpec.describe SyntageSdk::RateLimit do
  describe '.from_headers' do
    subject :rate_limit do
      described_class.from_headers \
        'X-RateLimit-Limit' => '60',
        'X-RateLimit-Remaining' => '56',
        'X-RateLimit-Reset' => '1606678044'
    end

    it 'parses the limit as an integer' do
      expect(rate_limit.limit).to eq(60)
    end

    it 'parses the remaining requests as an integer' do
      expect(rate_limit.remaining).to eq(56)
    end

    it 'parses the reset epoch as an integer' do
      expect(rate_limit.reset).to eq(1_606_678_044)
    end

    it 'exposes the reset time as a UTC Time' do
      expect(rate_limit.reset_at).to eq(Time.at(1_606_678_044).utc)
    end

    it 'is not exceeded while requests remain' do
      expect(rate_limit).not_to be_exceeded
    end
  end

  describe 'when the rate limit is exhausted' do
    subject :rate_limit do
      described_class.from_headers 'X-RateLimit-Remaining' => '0'
    end

    it 'is exceeded' do
      expect(rate_limit).to be_exceeded
    end
  end

  describe 'when the headers are absent' do
    subject(:rate_limit) { described_class.from_headers({}) }

    it 'leaves the values nil' do
      expect(rate_limit).to have_attributes(limit: nil, remaining: nil, reset: nil)
    end

    it 'has no reset time' do
      expect(rate_limit.reset_at).to be_nil
    end

    it 'is not considered exceeded' do
      expect(rate_limit).not_to be_exceeded
    end
  end
end
