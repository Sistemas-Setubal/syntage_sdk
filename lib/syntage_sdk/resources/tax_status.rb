# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxStatus < BaseResource
      include Listable

      FILTERS = {
        id_lt: 'id[lt]',
        id_gt: 'id[gt]'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/tax-status", LIST, options
      end
    end
  end
end
