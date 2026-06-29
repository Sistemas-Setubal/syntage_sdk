# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Addresses < BaseResource
      def lookup(postal_code)
        client.get "datasources/mx/addresses/#{postal_code}"
      end
    end
  end
end
