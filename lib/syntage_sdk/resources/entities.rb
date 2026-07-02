# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Entities < BaseResource
      include Listable
      include Retrievable

      PATH = 'entities'

      OPTIONAL_FIELDS = %i[rfc datasources].freeze

      UPDATE_FIELDS = %i[name tags].freeze

      LIST = ListConfig.new(
        filters: {
          rfc:         'taxpayer.id',
          name:        'taxpayer.name',
          person_type: 'taxpayer.personType',
          id_lt:       'id[lt]',
          id_gt:       'id[gt]'
        }.freeze,
        dates: {
          registration_date: 'taxpayer.registrationDate',
          updated_at:        'updatedAt'
        }.freeze,
        orders: {
          created_at: 'createdAt',
          updated_at: 'updatedAt'
        }.freeze
      ).freeze

      def list(**options)
        list_collection PATH, LIST, options
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

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
