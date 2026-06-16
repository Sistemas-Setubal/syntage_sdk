# frozen_string_literal: true

module SyntageSdk
  module Resources
    # Immutable description of how a resource lists: which option keys map to
    # which API params for filters, numeric ranges, extra date fields, and
    # ordering. Consumed by Listable; only `filters` is required.
    ListConfig = Data.define :filters, :numeric, :dates, :orders do
      def initialize(filters:, numeric: {}, dates: {}, orders: {})
        super
      end
    end
  end
end
