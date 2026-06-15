require_relative 'syntage_sdk/version'
require_relative 'syntage_sdk/errors'
require_relative 'syntage_sdk/headers'
require_relative 'syntage_sdk/rate_limit'
require_relative 'syntage_sdk/response_metadata'
require_relative 'syntage_sdk/response'
require_relative 'syntage_sdk/configuration'
require_relative 'syntage_sdk/client'
require_relative 'syntage_sdk/resources/base_resource'
require_relative 'syntage_sdk/resources/listable'
require_relative 'syntage_sdk/resources/entities'
require_relative 'syntage_sdk/resources/credentials'
require_relative 'syntage_sdk/resources/events'
require_relative 'syntage_sdk/resources/invoices'

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

    def client
      @client ||= Client.new
    end

    def entities
      Resources::Entities.new
    end

    def credentials
      Resources::Credentials.new
    end

    def events
      Resources::Events.new
    end

    def invoices
      Resources::Invoices.new
    end

    def reset_configuration!
      @configuration = Configuration.new
      @client = nil
    end
  end
end
