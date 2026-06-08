module SyntageSdk
  class RateLimit
    attr_reader :limit, :remaining, :reset

    def self.from_headers(raw)
      headers = Headers.new raw

      new \
        limit: Integer(headers.get('X-RateLimit-Limit'), exception: false),
        remaining: Integer(headers.get('X-RateLimit-Remaining'), exception: false),
        reset: Integer(headers.get('X-RateLimit-Reset'), exception: false)
    end

    def initialize(limit:, remaining:, reset:)
      @limit = limit
      @remaining = remaining
      @reset = reset
    end

    def reset_at
      Time.at(reset).utc if reset
    end

    def exceeded?
      remaining ? remaining <= 0 : false
    end
  end
end
