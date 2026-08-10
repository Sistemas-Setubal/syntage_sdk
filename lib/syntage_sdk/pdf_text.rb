# frozen_string_literal: true

require 'open3'
require 'tmpdir'

module SyntageSdk
  class PdfText
    DEFAULT_BINARY = 'pdftotext'
    BINARY_VARIABLE = 'SYNTAGE_PDFTOTEXT'
    LAYOUT = '-layout'
    STDOUT_TARGET = '-'
    FILENAME = 'document.pdf'

    def self.binary
      ENV.fetch BINARY_VARIABLE, DEFAULT_BINARY
    end

    def self.extract(bytes, binary: self.binary)
      Dir.mktmpdir do |dir|
        path = File.join dir, FILENAME
        File.binwrite path, bytes
        run binary, path
      end
    end

    def self.run(binary, path)
      out, err, status = Open3.capture3 binary, LAYOUT, path, STDOUT_TARGET
      raise DependencyError, "#{binary} failed: #{err.to_s.strip}" unless status.success?

      out
    rescue Errno::ENOENT
      raise DependencyError,
            "#{binary} not found. Install poppler-utils, set #{BINARY_VARIABLE} " \
            'or pass binary: to this call.'
    end
  end
end
