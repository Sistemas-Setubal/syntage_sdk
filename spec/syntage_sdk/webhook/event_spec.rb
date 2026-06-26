require 'syntage_sdk'

RSpec.describe SyntageSdk::Webhook::Event do
  let :payload do
    {
      'id'         => 'evt_abc123',
      'type'       => 'credential.created',
      'resource'   => '/credentials/cred_1',
      'data'       => { 'object' => { 'id' => 'cred_1', 'rfc' => 'XAXX010101000' } },
      'createdAt'  => '2026-06-26 17:41:15'
    }
  end

  subject(:event) { described_class.from_payload payload }

  it 'assigns the id' do
    expect(event.id).to eq('evt_abc123')
  end

  it 'assigns the type' do
    expect(event.type).to eq('credential.created')
  end

  it 'assigns the resource path' do
    expect(event.resource).to eq('/credentials/cred_1')
  end

  it 'assigns the data hash' do
    expect(event.data).to eq({ 'object' => { 'id' => 'cred_1', 'rfc' => 'XAXX010101000' } })
  end

  it 'assigns created_at from the createdAt key' do
    expect(event.created_at).to eq('2026-06-26 17:41:15')
  end

  it 'sets created_at to nil when the key is absent' do
    expect(described_class.from_payload(payload.except('createdAt')).created_at).to be_nil
  end

  it 'sets resource to nil when the key is absent' do
    expect(described_class.from_payload(payload.except('resource')).resource).to be_nil
  end
end
