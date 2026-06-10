# frozen_string_literal: true

require 'base64'

module SyntageSdk
  module Resources
    class Credentials < BaseResource
      PATH = 'credentials'

      def create_ciec(rfc:, password:)
        body = { type: 'ciec', rfc: rfc, password: password }
        client.post PATH, body: body
      end

      def create_efirma(certificate:, private_key:, password:)
        body = {
          type: 'efirma',
          certificate: encode(certificate),
          privateKey: encode(private_key),
          password: password
        }
        client.post PATH, body: body
      end

      private

      def encode(value)
        Base64.strict_encode64 value
      end
    end
  end
end
