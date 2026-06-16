# frozen_string_literal: true

module SyntageSdk
  module Resources
    ListConfig = Data.define :filters, :numeric, :dates, :orders do
      def initialize(filters:, numeric: {}, dates: {}, orders: {})
        super
      end
    end
  end
end
