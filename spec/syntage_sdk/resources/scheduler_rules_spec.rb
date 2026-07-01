require 'syntage_sdk'

RSpec.describe SyntageSdk::Resources::SchedulerRules do
  subject(:scheduler_rules) { described_class.new client }

  let(:client) { instance_double SyntageSdk::Client, get: response, post: response, put: response, delete: response }
  let(:response) { instance_double SyntageSdk::Response }

  describe '#create' do
    it 'posts to the scheduler rules path' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(path: 'schedulers/rules'))
    end

    it 'includes the scheduler IRI' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(scheduler: '/schedulers/sch_1')))
    end

    it 'includes the extractor' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(extractor: 'invoice')))
    end

    it 'raises when scheduler is missing' do
      expect { scheduler_rules.create extractor: 'invoice' }.to raise_error(ArgumentError)
    end

    it 'raises when extractor is missing' do
      expect { scheduler_rules.create scheduler: '/schedulers/sch_1' }.to raise_error(ArgumentError)
    end

    it 'includes the options when given' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice', options: { types: ['issued'] }

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(options: { types: ['issued'] })))
    end

    it 'forwards nested options verbatim without camelCasing inner keys' do
      nested = { types: ['I'], period: { from: '2020-01-01', to: '2020-03-31' } }
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice', options: nested

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(options: nested)))
    end

    it 'omits options when not given' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:options)))
    end

    it 'maps cron_expression to the camelCase cronExpression field' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice', cron_expression: '@daily'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_including(cronExpression: '@daily')))
    end

    it 'omits cronExpression when not given' do
      scheduler_rules.create scheduler: '/schedulers/sch_1', extractor: 'invoice'

      expect(client).to have_received(:post)
        .with(an_object_having_attributes(body: hash_excluding(:cronExpression)))
    end

    it 'returns the client response' do
      expect(scheduler_rules.create(scheduler: '/schedulers/sch_1', extractor: 'invoice')).to be(response)
    end
  end

  describe '#retrieve' do
    it 'gets the scheduler rule path with the id' do
      scheduler_rules.retrieve 'rule_1'

      expect(client).to have_received(:get).with('schedulers/rules/rule_1', anything)
    end

    it 'requests the JSON-LD representation' do
      scheduler_rules.retrieve 'rule_1'

      expect(client).to have_received(:get)
        .with(anything, hash_including(headers: hash_including('Accept' => 'application/ld+json')))
    end

    it 'returns the client response' do
      expect(scheduler_rules.retrieve('rule_1')).to be(response)
    end
  end

  describe '#update' do
    it 'puts to the scheduler rule path with the id' do
      scheduler_rules.update 'rule_1', cron_expression: '@daily'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(path: 'schedulers/rules/rule_1'))
    end

    it 'includes the extractor when given' do
      scheduler_rules.update 'rule_1', extractor: 'tax_status'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(extractor: 'tax_status')))
    end

    it 'maps cron_expression to the camelCase cronExpression field' do
      scheduler_rules.update 'rule_1', cron_expression: '@daily'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(cronExpression: '@daily')))
    end

    it 'includes the options when given' do
      scheduler_rules.update 'rule_1', options: { types: ['issued'] }

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_including(options: { types: ['issued'] })))
    end

    it 'omits fields that are not given' do
      scheduler_rules.update 'rule_1', cron_expression: '@daily'

      expect(client).to have_received(:put)
        .with(an_object_having_attributes(body: hash_excluding(:extractor)))
    end

    it 'returns the client response' do
      expect(scheduler_rules.update('rule_1', cron_expression: '@daily')).to be(response)
    end
  end

  describe '#destroy' do
    it 'deletes the scheduler rule path with the id' do
      scheduler_rules.destroy 'rule_1'

      expect(client).to have_received(:delete).with('schedulers/rules/rule_1')
    end

    it 'returns the client response' do
      expect(scheduler_rules.destroy('rule_1')).to be(response)
    end
  end
end
