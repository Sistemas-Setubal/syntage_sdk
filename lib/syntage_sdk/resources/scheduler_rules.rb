# frozen_string_literal: true

module SyntageSdk
  module Resources
    class SchedulerRules < BaseResource
      include Retrievable

      PATH = 'schedulers/rules'

      OPTIONAL_FIELDS = {
        options:         :options,
        cron_expression: :cronExpression
      }.freeze

      UPDATE_FIELDS = {
        extractor:       :extractor,
        options:         :options,
        cron_expression: :cronExpression
      }.freeze

      def create(scheduler:, extractor:, **options)
        body = { scheduler: scheduler, extractor: extractor }.merge(optional(OPTIONAL_FIELDS, options))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def update(id, **options)
        client.put WriteRequest.new(path: "#{PATH}/#{id}", body: optional(UPDATE_FIELDS, options))
      end

      def destroy(id)
        client.delete "#{PATH}/#{id}"
      end

      private

      def optional(fields, options)
        fields.each_with_object({}) do |(ruby_key, api_key), body|
          value = options[ruby_key]
          next if value.nil?

          body[api_key] = value
        end
      end
    end
  end
end
