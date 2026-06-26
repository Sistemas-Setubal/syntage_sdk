# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Schedulers < BaseResource
      include Retrievable

      PATH = 'schedulers'

      DEFAULT_TYPE = 'recurring'

      OPTIONAL_FIELDS = {
        name:       :name,
        is_enabled: :isEnabled,
        tags:       :tags
      }.freeze

      def create(type: DEFAULT_TYPE, **options)
        body = { type: type }.merge(optional(options))
        client.post PATH, body: body
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def delete(id)
        client.delete "#{PATH}/#{id}"
      end

      private

      def optional(options)
        OPTIONAL_FIELDS.each_with_object({}) do |(ruby_key, api_key), body|
          value = options[ruby_key]
          next if value.nil?

          body[api_key] = value
        end
      end
    end
  end
end
