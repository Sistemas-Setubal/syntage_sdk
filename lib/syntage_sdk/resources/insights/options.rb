# frozen_string_literal: true

module SyntageSdk
  module Resources
    class Insights
      module Options
        private

        def options_query(values, *keys)
          keys.to_h { |key| ["options[#{key}]", values[key]] }.compact
        end
      end
    end
  end
end
