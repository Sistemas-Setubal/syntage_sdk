# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      module DateRange
        private

        def date_range(options)
          { 'options[from]' => options[:from], 'options[to]' => options[:to] }.compact
        end
      end
    end
  end
end
