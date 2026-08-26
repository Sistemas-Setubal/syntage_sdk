# frozen_string_literal: true

module SyntageSdk
  class Transcript
    LABELS = {
      top:    {
        'TOTAL DE INGRESOS ACUMULABLES' => :accruable_income,
        'TOTAL DE DEDUCCIONES AUTORIZADAS' => :authorized_deductions,
        'PTU PAGADA EN EL EJERCICIO' => :profit_sharing_paid,
        'PÉRDIDA FISCAL DEL EJERCICIO' => :tax_loss,
        'RESULTADO FISCAL' => :taxable_result,
        'IMPUESTO CAUSADO DEL EJERCICIO' => :tax_incurred,
        'IMPUESTO SOBRE LA RENTA DEL EJERCICIO' => :isr_for_year,
        'PAGOS PROVISIONALES EFECTUADOS' => :provisional_payments,
        'ISR RETENIDO AL CONTRIBUYENTE' => :withheld_isr,
        'ISR A CARGO DEL EJERCICIO' => :isr_payable,
        'COEFICIENTE DE UTILIDAD DEL EJERCICIO' => :profit_coefficient
      }.freeze,
      nested: {
        'UTILIDAD FISCAL PARA COEFICIENTE DE UTILIDAD' => :taxable_profit_for_coefficient,
        'PÉRDIDA FISCAL PARA COEFICIENTE DE UTILIDAD' => :tax_loss_for_coefficient,
        'AJUSTE ANUAL POR INFLACIÓN ACUMULABLE' => :inflation_adjustment,
        'INGRESOS NOMINALES PARA COEFICIENTE DE UTILIDAD' => :nominal_income_for_coefficient
      }.freeze,
      flags:  {
        '¿TE AUTORIZARON APLICAR UN COEFICIENTE DE UTILIDAD MENOR EN PAGOS PROVISIONALES ' \
        'AL DETERMINADO EN EL EJERCICIO?' => :lower_coefficient_authorized
      }.freeze
    }.freeze

    DECIMALS = [:profit_coefficient].freeze

    EMPTY = LABELS.values.flat_map(&:values).to_h { |field| [field, nil] }.freeze

    CONCEPT = /\A(\s*)(\S[^\t]*?)\s{2,}(-?[\d,]+(?:\.\d+)?)\s*\z/

    ANSWER = /\A(¿[^\t]*?)\s{2,}(S[IÍ]|NO)\s*\z/i

    def self.parse(text)
      new(text).determination
    end

    def initialize(text)
      @lines = text.to_s.lines.map { |line| line.chomp.rstrip }
    end

    def determination
      @lines.each_with_object(EMPTY.dup).with_index do |(line, found), index|
        record found, line, index
      end
    end

    private

    def record(found, line, index)
      concept = CONCEPT.match line
      return concept_of found, concept, index if concept

      answer = ANSWER.match line
      return unless answer

      assign found, LABELS[:flags][question(answer[1], index)], affirmative?(answer[2])
    end

    def concept_of(found, concept, index)
      indent, text, raw = concept.captures
      table = table_for indent
      field = table[label(table, text, index)]

      assign found, field, value_for(field, raw)
    end

    def table_for(indent)
      return LABELS[:top] if indent.empty?

      LABELS[:nested]
    end

    def label(table, text, index)
      base = text.strip
      return base if table.key? base

      joined = "#{base} #{continuation index}".strip
      return joined if table.key? joined

      base
    end

    def continuation(index)
      following = @lines[index + 1].to_s.strip
      return '' if following.empty? || CONCEPT.match?(following)

      following
    end

    def question(text, index)
      parts = [text.strip]

      @lines[index + 1, 3].to_a.each do |following|
        line = following.strip
        break if line.empty? || parts.last.end_with?('?')

        parts << line
      end

      parts.join ' '
    end

    def assign(found, field, value)
      return unless field
      return unless found[field].nil?

      found[field] = value
    end

    def affirmative?(raw)
      !raw.casecmp?('NO')
    end

    def value_for(field, raw)
      return raw.delete(',').to_f if DECIMALS.include? field

      amount raw
    end

    def amount(raw)
      value = raw.delete(',').to_f
      return value.to_i if (value % 1).zero?

      value
    end
  end
end
