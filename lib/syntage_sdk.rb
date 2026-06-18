require_relative 'syntage_sdk/boot'

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

<<<<<<< HEAD
    def tax_returns
      Resources::TaxReturns.new
=======
    def payments
      Resources::Payments.new
>>>>>>> 7808620452d521b4ded414aa8cc2ebb26fd963ea
    end

    def insights(entity_id)
      Resources::Insights.new entity_id
    end

    def rug(entity_id)
      Resources::Rug.new entity_id
    end

    def reset_configuration!
      @configuration = Configuration.new
      @client = nil
    end
  end
end
