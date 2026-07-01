# frozen_string_literal: true

module SyntageSdk
  module Resources
    class SyntageScore < EntityScopedResource
      def calculate
        client.post WriteRequest.new(path: "entities/#{entity_id}/datasources/syntage/score/calculate", body: {})
      end
    end
  end
end
