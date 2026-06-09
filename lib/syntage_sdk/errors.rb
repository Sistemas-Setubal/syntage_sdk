module SyntageSdk
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ApiError < Error
    attr_reader :metadata

    def initialize(message = nil, metadata: nil)
      @metadata = metadata
      super(message)
    end

    def request_id
      metadata&.request_id
    end
  end

  class AuthenticationError < ApiError; end

  class RateLimitError < ApiError
    def rate_limit
      metadata&.rate_limit
    end
  end
end
