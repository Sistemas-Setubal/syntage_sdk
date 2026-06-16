# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Events < BaseResource
      include Listable

      PATH = 'events'

      FILTERS = {
        type: 'type',
        taxpayer_id: 'taxpayer.id',
        source: 'source',
        resource: 'resource'
      }.freeze

      LIST = ListConfig.new(filters: FILTERS).freeze

      def list(**options)
        list_collection PATH, LIST, options
      end
    end
  end
end
