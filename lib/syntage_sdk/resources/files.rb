# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Files < BaseResource
      include Retrievable

      PATH = 'files'

      DOWNLOAD_ACCEPT = '*/*'

      def retrieve(id)
        retrieve_resource "#{PATH}/#{id}"
      end

      def download(id)
        client.get "#{PATH}/#{id}/download", headers: { 'Accept' => DOWNLOAD_ACCEPT }
      end
    end
  end
end
