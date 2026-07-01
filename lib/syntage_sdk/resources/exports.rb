# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Exports < BaseResource
      include Retrievable

      PATH = 'exports'

      OPTIONAL_FIELDS = {
        file_types: :fileTypes
      }.freeze

      def create(format:, uri:, **options)
        body = { format: format, uri: uri }.merge(optional(options))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
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
