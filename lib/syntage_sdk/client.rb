# frozen_string_literal: true

require 'httparty'
require 'json'

module SyntageSdk
  class Client
    UNAUTHORIZED_MESSAGE = 'Syntage API authentication failed (401). Check your API key.'
    RATE_LIMIT_MESSAGE = 'Syntage API rate limit exceeded (429).'
    RETRY_BACKOFF = 0.5

    def initialize(configuration = SyntageSdk.configuration)
      @configuration = configuration
    end

    def get(path, query: nil)
      request { HTTParty.get url_for(path), request_options(query: query) }
    end

    def post(path, body: nil)
      request { HTTParty.post url_for(path), request_options(body: body) }
    end

    private

    def request
      response = with_retries { yield }
      handle response
    end

    def with_retries
      attempts = 0
      loop do
        response = yield
        return response unless retryable? response, attempts

        attempts += 1
        pause attempts
      end
    end

    def retryable?(response, attempts)
      response.code == 429 && attempts < @configuration.max_retries
    end

    def pause(attempts)
      sleep RETRY_BACKOFF * (2**(attempts - 1))
    end

    def handle(response)
      status = response.code
      metadata = ResponseMetadata.from_headers normalize(response.headers)
      return build_response response, status, metadata if status.between? 200, 299

      raise_error status, metadata
    end

    def raise_error(status, metadata)
      raise RateLimitError.new(RATE_LIMIT_MESSAGE, metadata: metadata) if status == 429
      raise AuthenticationError.new(UNAUTHORIZED_MESSAGE, metadata: metadata) if status == 401

      raise ApiError.new("Unexpected Syntage API response (#{status}).", metadata: metadata)
    end

    def build_response(response, status, metadata)
      Response.new status: status, body: response.parsed_response, metadata: metadata
    end

    def request_options(query: nil, body: nil)
      result = { headers: @configuration.headers, timeout: @configuration.timeout }
      result[:query] = query if query
      result[:body] = JSON.generate(body) if body
      result
    end

    def url_for(path)
      base = @configuration.base_url.chomp '/'
      suffix = path.to_s.sub %r{\A/}, ''
      "#{base}/#{suffix}"
    end

    def normalize(headers)
      headers.to_hash.transform_values { |value| Array(value).first }
    end
  end
end
