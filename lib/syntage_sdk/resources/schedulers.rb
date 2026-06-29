# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Schedulers < BaseResource
      include Listable
      include Retrievable

      PATH = 'schedulers'

      DEFAULT_TYPE = 'recurring'

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      OPTIONAL_FIELDS = {
        name:       :name,
        is_enabled: :isEnabled,
        tags:       :tags
      }.freeze

      def list(**options)
        list_collection PATH, LIST, options
      end

      def create(type: DEFAULT_TYPE, **options)
        body = { type: type }.merge(optional(options))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def update(id, **options)
        client.put WriteRequest.new(path: "#{PATH}/#{id}", body: optional(options))
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
