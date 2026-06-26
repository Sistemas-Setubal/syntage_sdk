require 'syntage_sdk'
require 'openssl'
require 'stringio'

RSpec.describe SyntageSdk::Webhook::Middleware do
  let(:secret)     { 'test_webhook_secret' }
  let(:inner_app)  { spy 'rack_app' }
  let(:middleware) { described_class.new inner_app, secret: secret }
  let :body do
    '{"id":"evt_1","type":"credential.created","resource":"/credentials/cred_1",' \
    '"data":{"object":{"id":"cred_1"}},"createdAt":"2026-06-26 17:41:15"}'
  end

  before { allow(inner_app).to receive(:call).and_return([200, {}, ['ok']]) }

  def valid_sig(raw_body, timestamp: Time.now.to_i.to_s)
    signed = "#{timestamp}.#{raw_body}"
    sig    = OpenSSL::HMAC.hexdigest 'SHA256', secret, signed
    "t=#{timestamp},s=#{sig}"
  end

  def env_for(raw_body, signature: valid_sig(raw_body))
    { 'rack.input' => StringIO.new(raw_body), described_class::SIGNATURE_HEADER => signature }
  end

  context 'with a valid signature' do
    it 'forwards the request to the inner app' do
      middleware.call env_for(body)

      expect(inner_app).to have_received(:call)
    end

    it 'returns the inner app response' do
      expect(middleware.call(env_for(body))).to eq([200, {}, ['ok']])
    end

    it 'injects a Webhook::Event into the Rack env' do
      env = env_for body
      middleware.call env

      expect(env[described_class::EVENT_ENV_KEY]).to be_a(SyntageSdk::Webhook::Event)
    end

    it 'sets the event type on the injected event' do
      env = env_for body
      middleware.call env

      expect(env[described_class::EVENT_ENV_KEY].type).to eq('credential.created')
    end
  end

  context 'with a tampered body (wrong signature)' do
    it 'returns 401' do
      env = env_for body, signature: valid_sig('different body')

      expect(middleware.call(env).first).to eq(401)
    end

    it 'does not call the inner app' do
      env = env_for body, signature: valid_sig('different body')
      middleware.call env

      expect(inner_app).not_to have_received(:call)
    end
  end

  context 'with a signature of the wrong length' do
    it 'returns 401' do
      expect(middleware.call(env_for(body, signature: 't=123,s=short')).first).to eq(401)
    end
  end

  context 'with a stale timestamp' do
    it 'returns 401' do
      old_ts = (Time.now.to_i - 600).to_s

      expect(middleware.call(env_for(body, signature: valid_sig(body, timestamp: old_ts))).first).to eq(401)
    end
  end

  context 'with a non-numeric timestamp' do
    it 'returns 401' do
      bad_sig = "t=abc,s=#{'f' * 64}"
      expect(middleware.call(env_for(body, signature: bad_sig)).first).to eq(401)
    end
  end

  context 'with a missing signature header' do
    it 'returns 401' do
      env = { 'rack.input' => StringIO.new(body) }

      expect(middleware.call(env).first).to eq(401)
    end
  end

  context 'with an invalid JSON body' do
    it 'returns 400' do
      expect(middleware.call(env_for('not json')).first).to eq(400)
    end
  end

  context 'when secret is not configured' do
    let(:middleware) { described_class.new inner_app, secret: nil }

    it 'raises ConfigurationError' do
      expect { middleware.call env_for(body) }.to raise_error(SyntageSdk::ConfigurationError)
    end
  end
end
