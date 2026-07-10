# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Extractions < BaseResource
      include Listable
      include Retrievable

      PATH = 'extractions'

      FILTERS = {
        extractor: 'extractor',
        status: 'status',
        datasource: 'datasource',
        taxpayer_id: 'taxpayer.id',
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      EXTRA_DATE_FIELDS = {
        started_at: 'startedAt',
        finished_at: 'finishedAt',
        billing_date: 'billingDate',
        updated_at: 'updatedAt'
      }.freeze

      ORDER_FIELDS = {
        id: 'id',
        started_at: 'startedAt',
        finished_at: 'finishedAt',
        billing_date: 'billingDate'
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

      def create(entity:, extractor:, **params)
        body = { entity: entity, extractor: extractor }.merge(optional(params))
        client.post WriteRequest.new(path: PATH, body: body)
      end

      def stop(id)
        client.delete "#{PATH}/#{id}/stop"
      end

      private

      def optional(params)
        params.slice(:options).compact
      end
    end
  end
end
