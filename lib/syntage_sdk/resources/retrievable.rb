# frozen_string_literal: true

module SyntageSdk
  module Resources
    module Retrievable
      LD_JSON = 'application/ld+json'

      private

      def retrieve_resource(path)
        client.get path, headers: { 'Accept' => LD_JSON }
      end
    end
  end
end
