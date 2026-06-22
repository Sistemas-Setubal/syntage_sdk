# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Shareholders < BaseResource
      include Listable
      include Retrievable

      CREATE_OPTIONAL = %i[rfc].freeze
      UPDATE_OPTIONAL = %i[name rfc].freeze

      FILTERS = {
        type: 'type',
        name: 'name',
        rfc:  'rfc'
      }.freeze

      ORDER_FIELDS = {
        name:       'name',
        created_at: 'createdAt',
        updated_at: 'updatedAt'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS, orders: ORDER_FIELDS).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/shareholders", LIST, options
      end

      def list_all(**options)
        list_collection 'shareholders', LIST, options
      end

      def retrieve(id)
        retrieve_resource "shareholders/#{id}"
      end

      def create(entity_id:, **attributes)
        body = {
          relationType: fetch_required(attributes, :relation_type),
          name:         fetch_required(attributes, :name),
          shares:       fetch_required(attributes, :shares)
        }.merge(attributes.slice(*CREATE_OPTIONAL).compact)
        client.post "entities/#{entity_id}/shareholders", body: body
      end

      def update(id, **options)
        body = options.slice(*UPDATE_OPTIONAL).compact
        client.patch "shareholders/#{id}", body: body
      end

      def delete(id)
        client.delete "shareholders/#{id}"
      end

      private

      def fetch_required(hash, key)
        hash.fetch(key) { raise ArgumentError, "missing keyword: #{key}" }
      end
    end
  end
end
