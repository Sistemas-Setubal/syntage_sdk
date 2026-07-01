# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Entities < BaseResource
      PATH = 'entities'

      OPTIONAL_FIELDS = %i[rfc datasources].freeze

      UPDATE_FIELDS = %i[name tags].freeze

      def create(name:, type:, **options)
        body = { name: name, type: type }.merge(optional(options))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def update(id, **options)
        body = options.slice(*UPDATE_FIELDS).compact
        client.patch WriteRequest.new(path: "#{PATH}/#{id}", body: body)
      end

      private

      def optional(options)
        options.slice(*OPTIONAL_FIELDS).compact
      end
    end
  end
end
