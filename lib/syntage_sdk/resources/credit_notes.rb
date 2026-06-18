# frozen_string_literal: true

module SyntageSdk
  module Resources
    class CreditNotes < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(**options)
        list_collection 'invoices/credit-notes', LIST, options
      end

      def issued(invoice_id:, **options)
        list_collection "invoices/#{invoice_id}/issued-credit-notes", LIST, options
      end

      def applied(invoice_id:, **options)
        list_collection "invoices/#{invoice_id}/applied-credit-notes", LIST, options
      end

      def retrieve(id)
        retrieve_resource "invoices/credit-note/#{id}"
      end
    end
  end
end
