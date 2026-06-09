# frozen_string_literal: true

module SyntageSdk
  module Resources
    class BaseResource
      def initialize(client = SyntageSdk.client)
        @client = client
      end

      private

      attr_reader :client
    end
  end
end
