# frozen_string_literal: true

module SyntageSdk
  class AckReceipt
    CONCEPT = /\AConcepto (?:de pago|presentado)\s+\d+\s*:\s*(.*)\z/
    WRAPPED_NAME = /\A\d*\z/

    FIELDS = {
      'A cargo' => :a_cargo,
      'Impuesto a cargo' => :a_cargo,
      'A favor' => :a_favor,
      'Parte actualizada' => :actualizacion,
      'Recargos' => :recargos,
      'Monto pagado con anterioridad' => :pagado_con_anterioridad,
      'Cantidad a cargo' => :cantidad_a_cargo,
      'Cantidad a favor' => :cantidad_a_favor,
      'Cantidad a pagar' => :cantidad_a_pagar
    }.freeze

    FIELD = /\A(#{Regexp.union FIELDS.keys})\s*:\s*\$?([\d,.]*)\z/

    AMOUNTS = { a_cargo: nil, a_favor: nil, actualizacion: nil, recargos: nil,
                pagado_con_anterioridad: nil, cantidad_a_cargo: nil,
                cantidad_a_favor: nil, cantidad_a_pagar: nil }.freeze

    def self.parse(text)
      new(text).concepts
    end

    def initialize(text)
      @lines = text.to_s.lines.map(&:strip)
      @concepts = []
    end

    def concepts
      @lines.each_with_index { |line, index| consume line, index }
      @concepts
    end

    private

    def consume(line, index)
      concept = CONCEPT.match line
      return open_concept concept[1], index if concept

      field = FIELD.match line
      return unless field

      add_field field
    end

    def open_concept(name, index)
      resolved = resolve_name name, index

      @concepts << AMOUNTS.merge(name: resolved, bucket: ConceptBucket.for(resolved))
    end

    def resolve_name(name, index)
      return name unless name.match? WRAPPED_NAME

      [preceding(index), @lines[index + 1]].compact.reject { |line| noise? line }.join ' '
    end

    def preceding(index)
      return nil unless index.positive?

      @lines[index - 1]
    end

    def noise?(line)
      line.empty? || line.end_with?(':') || CONCEPT.match?(line) || FIELD.match?(line)
    end

    def add_field(field)
      current = @concepts.last
      return unless current

      current[FIELDS.fetch(field[1])] = amount field[2]
    end

    def amount(raw)
      return nil if raw.empty?

      value = raw.delete(',').to_f
      return value.to_i if (value % 1).zero?

      value
    end
  end
end
