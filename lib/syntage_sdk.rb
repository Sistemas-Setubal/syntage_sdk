require_relative 'syntage_sdk/version'
require_relative 'syntage_sdk/errors'
require_relative 'syntage_sdk/headers'
require_relative 'syntage_sdk/rate_limit'
require_relative 'syntage_sdk/response_metadata'
require_relative 'syntage_sdk/configuration'

module SyntageSdk
  class << self
    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield configuration
      configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
