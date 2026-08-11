# frozen_string_literal: true

module SyntageSdk
  module Resources
    class TaxReturns < BaseResource
      include Listable
      include Retrievable

      FILTERS = {
        type:             'type',
        interval_unit:    'intervalUnit',
        complementary:    'complementary',
        capture_line:     'captureLine',
        operation_number: 'operationNumber',
        fiscal_year:      'fiscalYear',
        period:           'period'
      }.freeze

      EXTRA_DATE_FIELDS = {
        presented_at: 'presentedAt'
      }.freeze

      ORDER_FIELDS = {
        period:       'period',
        presented_at: 'presentedAt'
      }.freeze

      LIST = ListConfig.new(
        filters: FILTERS,
        dates:   EXTRA_DATE_FIELDS,
        orders:  ORDER_FIELDS
      ).freeze

      FILES = { ack_receipt: 'tax_return.ack_receipt', transcript: 'tax_return.transcript' }.freeze

      def list(entity_id:, **options)
        list_collection "entities/#{entity_id}/tax-returns", LIST, options
      end

      def retrieve(id)
        retrieve_resource "tax-returns/#{id}"
      end

      def data(id)
        client.get "tax-returns/#{id}/data", headers: { 'Accept' => 'application/json' }
      end

      def pdf(id)
        client.get "tax-returns/#{id}/pdf", headers: { 'Accept' => 'application/pdf' }
      end

      def amounts(id)
        ack = file_of retrieve(id).body, :ack_receipt
        return [] unless ack

        AckReceipt.parse text_of(ack)
      end

      def determination(id)
        transcript = file_of retrieve(id).body, :transcript
        return nil unless transcript

        Transcript.parse text_of(transcript)
      end

      private

      def file_of(body, kind)
        type = FILES.fetch kind
        files = body['files'] || []

        files.find { |file| file['type'] == type }
      end

      def text_of(file)
        PdfText.extract Files.new(client).download(file['id']).body
      end
    end
  end
end
