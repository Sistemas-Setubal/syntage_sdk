module SyntageSdk
  class Response
    attr_reader :status, :body, :metadata

    def initialize(status:, body:, metadata:)
      @status = status
      @body = body
      @metadata = metadata
    end

    def request_id
      metadata&.request_id
    end

    def rate_limit
      metadata&.rate_limit
    end

    def success?
      status.between? 200, 299
    end
  end
end
