# frozen_string_literal: true

module SyntageSdk
  WriteRequest = Data.define :path, :body do
    def initialize(path:, body: nil)
      super
    end
  end
end
