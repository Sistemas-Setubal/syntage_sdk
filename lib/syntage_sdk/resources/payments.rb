# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Payments < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(invoice_id: nil, **options)
        list_collection payments_path(invoice_id), LIST, options
      end

      def retrieve(id)
        retrieve_resource "invoices/payments/#{id}"
      end

      private

      def payments_path(invoice_id)
        return 'invoices/payments' if invoice_id.nil?

        "invoices/#{invoice_id}/payments"
      end
    end
  end
end
