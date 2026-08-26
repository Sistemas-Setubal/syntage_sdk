# frozen_string_literal: true

require 'base64'

module SyntageSdk
  module Resources
    class Credentials < BaseResource
      include Listable
      include Retrievable

      PATH = 'credentials'

      FILTERS = {
        type: 'type',
        rfc: 'rfc',
        status: 'status',
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      EXTRA_DATE_FIELDS = {
        updated_at: 'updatedAt'
      }.freeze

      ORDER_FIELDS = {
        id: 'id',
        created_at: 'createdAt',
        updated_at: 'updatedAt'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        dates: EXTRA_DATE_FIELDS,
        orders: ORDER_FIELDS
      ).freeze

      def list(**options)
        list_collection PATH, LIST, options
      end

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def create_ciec(rfc:, password:)
        body = { type: 'ciec', rfc: rfc, password: password }
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def create_efirma(certificate:, private_key:, password:)
        body = {
          type: 'efirma',
          certificate: encode(certificate),
          privateKey: encode(private_key),
          password: password
        }
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def revalidate(id)
        client.post WriteRequest.new(path: "#{PATH}/#{id}/revalidate", body: {})
      end

      def destroy(id)
        client.delete "#{PATH}/#{id}"
      end

      private

      def encode(value)
        Base64.strict_encode64 value
      end
    end
  end
end
