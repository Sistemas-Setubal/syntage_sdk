# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Entities < BaseResource
      PATH = 'entities'

      OPTIONAL_FIELDS = %i[rfc datasources].freeze

      def create(name:, type:, **options)
        body = { name: name, type: type }.merge(optional(options))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      private

      def optional(options)
        options.slice(*OPTIONAL_FIELDS).compact
      end
    end
  end
end
