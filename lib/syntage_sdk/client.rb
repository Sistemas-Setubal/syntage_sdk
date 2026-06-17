# frozen_string_literal: true

require 'httparty'
require 'json'

module SyntageSdk
  class Client
    RETRY_BACKOFF = 0.5

    JSON_MEDIA_TYPES = ['application/json', 'application/ld+json'].freeze

    ERROR_CLASSES = {
      400 => ValidationError,
      401 => AuthenticationError,
      403 => ForbiddenError,
      422 => ValidationError,
      429 => RateLimitError
    }.freeze

    STATUS_MESSAGES = {
      400 => 'Syntage API rejected the request (400).',
      401 => 'Syntage API authentication failed (401). Check your API key.',
      403 => 'Syntage API forbidden (403). The API key lacks permission for this request.',
      422 => 'Syntage API could not process the request (422).',
      429 => 'Syntage API rate limit exceeded (429).'
    }.freeze

    def initialize(configuration = SyntageSdk.configuration)
      @configuration = configuration
    end

    def get(path, query: nil, headers: nil)
      request { HTTParty.get url_for(path), request_options(query: query, headers: headers) }
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

      raise_error status, metadata, response.parsed_response
    end

    def raise_error(status, metadata, body)
      error_class = ERROR_CLASSES.fetch status, ApiError
      raise error_class.new(message_for(status, body), metadata: metadata, body: body)
    end

    def message_for(status, body)
      base = STATUS_MESSAGES.fetch(status) { "Unexpected Syntage API response (#{status})." }
      return base if body.nil?

      "#{base} #{body}"
    end

    def build_response(response, status, metadata)
      Response.new status: status, body: response.parsed_response, metadata: metadata
    end

    def request_options(query: nil, body: nil, headers: nil)
      merged = merged_headers headers
      json = JSON_MEDIA_TYPES.include? merged['Accept']
      result = { headers: merged, timeout: @configuration.timeout, format: json ? :json : :plain }
      result[:query] = query if query
      result[:body] = JSON.generate(body) if body
      result
    end

    def merged_headers(headers)
      base = @configuration.headers
      return base unless headers

      base.merge headers
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
