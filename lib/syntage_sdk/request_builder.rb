# frozen_string_literal: true

require 'json'

module SyntageSdk
  class RequestBuilder
    RESPONSE_PARSERS = {
      'application/json' => :json,
      'application/ld+json' => :json
    }.freeze

    def initialize(configuration)
      @configuration = configuration
    end

    def url_for(path)
      base = @configuration.base_url.chomp '/'
      suffix = path.to_s.sub %r{\A/}, ''
      "#{base}/#{suffix}"
    end

    def options(query: nil, body: nil, headers: nil)
      merged = merged_headers headers
      format = RESPONSE_PARSERS.fetch merged['Accept'], :plain
      result = { headers: merged, timeout: @configuration.timeout, format: format }
      result[:query] = query if query
      result[:body] = JSON.generate(body) if body
      result
    end

    private

    def merged_headers(headers)
      base = @configuration.headers
      return base unless headers

      base.merge headers
    end
  end
end
