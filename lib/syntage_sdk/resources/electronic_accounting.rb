# frozen_string_literal: true

module SyntageSdk
  module Resources
    class ElectronicAccounting < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        year:      'year',
        month:     'month',
        type:      'type',
        reason:    'reason',
        file_type: 'fileType',
        filename:  'filename',
        code:      'code',
        status:    'status',
        id_lt:     'id[lt]',
        id_gt:     'id[gt]'
      }.freeze

      DATE_FIELDS = {
        received_at: 'receivedAt'
      }.freeze

      ORDER_FIELDS = {
        year:        'year',
        month:       'month',
        received_at: 'receivedAt'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        dates:   DATE_FIELDS,
        orders:  ORDER_FIELDS
      ).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/electronic-accounting-records", LIST, options
      end

      def retrieve(id)
        retrieve_resource "electronic-accounting-records/#{id}"
      end
    end
  end
end
