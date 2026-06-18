# frozen_string_literal: true

module SyntageSdk
  module Resources
    class LineItems < BaseResource
      include Listable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(invoice_id:, **options)
        list_collection "invoices/#{invoice_id}/line-items", LIST, options
      end
    end
  end
end
