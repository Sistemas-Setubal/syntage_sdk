# frozen_string_literal: true

module SyntageSdk
  module Resources
    module CfdiRetrievable
      CFDI_MEDIA_TYPES = {
        json: 'application/json',
        xml:  'text/xml',
        pdf:  'application/pdf'
      }.freeze

      private

      def retrieve_cfdi(path, format)
        accept = CFDI_MEDIA_TYPES.fetch format do
          raise ArgumentError, "unsupported CFDI format #{format.inspect}, expected #{CFDI_MEDIA_TYPES.keys.join ', '}"
        end

        client.get path, headers: { 'Accept' => accept }
      end
    end
  end
end
