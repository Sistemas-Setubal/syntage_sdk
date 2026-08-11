# frozen_string_literal: true

module SyntageSdk
  class Transcript
    FIELDS = {
      'TOTAL DE INGRESOS ACUMULABLES' => :accruable_income,
      'TOTAL DE DEDUCCIONES AUTORIZADAS' => :authorized_deductions,
      'PTU PAGADA EN EL EJERCICIO' => :profit_sharing_paid,
      'PÉRDIDA FISCAL DEL EJERCICIO' => :tax_loss,
      'RESULTADO FISCAL' => :taxable_result,
      'IMPUESTO CAUSADO DEL EJERCICIO' => :tax_incurred,
      'IMPUESTO SOBRE LA RENTA DEL EJERCICIO' => :isr_for_year,
      'PAGOS PROVISIONALES EFECTUADOS' => :provisional_payments,
      'ISR RETENIDO AL CONTRIBUYENTE' => :withheld_isr,
      'ISR A CARGO DEL EJERCICIO' => :isr_payable
    }.freeze

    EMPTY = FIELDS.values.to_h { |field| [field, nil] }.freeze

    CONCEPT = /\A(\S[^\t]*?)\s{2,}(-?[\d,]+(?:\.\d+)?)\s*\z/

    CONTINUATION = /\A(\S[^\t]*?)\s*\z/

    def self.parse(text)
      new(text).determination
    end

    def initialize(text)
      @lines = text.to_s.lines.map { |line| line.chomp.rstrip }
    end

    def determination
      @lines.each_with_object(EMPTY.dup).with_index do |(line, found), index|
        concept = CONCEPT.match line
        next unless concept

        assign found, label(concept[1], index), concept[2]
      end
    end

    private

    def label(text, index)
      base = text.strip
      return base if FIELDS.key? base

      joined = "#{base} #{continuation index}".strip
      return joined if FIELDS.key? joined

      base
    end

    def continuation(index)
      following = @lines[index + 1].to_s
      return '' if following.empty? || CONCEPT.match?(following)

      CONTINUATION.match(following)&.captures&.first.to_s
    end

    def assign(found, label, raw)
      field = FIELDS[label]
      return unless field
      return unless found[field].nil?

      found[field] = amount raw
    end

    def amount(raw)
      value = raw.delete(',').to_f
      return value.to_i if (value % 1).zero?

      value
    end
  end
end
