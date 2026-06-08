module SyntageSdk
  class ResponseMetadata
    attr_reader :request_id, :rate_limit

    def self.from_headers(raw)
      new \
        request_id: Headers.new(raw).get('X-Request-ID'),
        rate_limit: RateLimit.from_headers(raw)
    end

    def initialize(request_id:, rate_limit:)
      @request_id = request_id
      @rate_limit = rate_limit
    end
  end
end
