# frozen_string_literal: true

module SyntageSdk
  module Webhook
    Event = Struct.new :id, :type, :resource, :data, :created_at, keyword_init: true do
      def self.from_payload(payload)
        new \
          id:         payload['id'],
          type:       payload['type'],
          resource:   payload['resource'],
          data:       payload['data'],
          created_at: payload['createdAt']
      end
    end
  end
end
