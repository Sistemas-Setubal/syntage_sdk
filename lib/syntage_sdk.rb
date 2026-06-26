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

    def tax_returns
      Resources::TaxReturns.new
    end

    def payments
      Resources::Payments.new
    end

    def batch_payments
      Resources::BatchPayments.new
    end

    def line_items
      Resources::LineItems.new
    end

    def credit_notes
      Resources::CreditNotes.new
    end

    def tax_status
      Resources::TaxStatus.new
    end

    def tax_compliance_checks
      Resources::TaxComplianceChecks.new
    end

    def tax_retentions
      Resources::TaxRetentions.new
    end

    def electronic_accounting
      Resources::ElectronicAccounting.new
    end

    def insights(entity_id)
      Resources::Insights.new entity_id
    end

    def rug(entity_id)
      Resources::Rug.new entity_id
    end

    def shareholders
      Resources::Shareholders.new
    end

    def background_checks
      Resources::BackgroundChecks.new
    end

    def company_verification_reports
      Resources::CompanyVerificationReports.new
    end

    def syntage_score(entity_id)
      Resources::SyntageScore.new entity_id
    end

    def rpc_entities(entity_id)
      Resources::RpcEntities.new entity_id
    end

    def sat_certificates(entity_id)
      Resources::SatCertificates.new entity_id
    end

    def schedulers
      Resources::Schedulers.new
    end

    def reset_configuration!
      @configuration = Configuration.new
      @client = nil
    end
  end
end
