# frozen_string_literal: true

module SyntageSdk
  module Resources
    class BatchPayments < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(invoice_id: nil, **options)
        list_collection batch_payments_path(invoice_id), LIST, options
      end

      def retrieve(id)
        retrieve_resource "invoices/batch-payments/#{id}"
      end

      private

      def batch_payments_path(invoice_id)
        return 'invoices/batch-payments' if invoice_id.nil?

        "invoices/#{invoice_id}/batch-payments"
      end
    end
  end
end
