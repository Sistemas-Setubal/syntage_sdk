# frozen_string_literal: true

module SyntageSdk
  class ConceptBucket
    RETAINED = /RETENCI|POR CUENTA DE TERCEROS/i
    IVA = /IVA|VALOR AGREGADO/i
    ISR = /ISR|SOBRE LA RENTA/i

    def self.for(name)
      return retained_or name, :iva_retenciones, :iva if name.match? IVA
      return retained_or name, :isr_retenciones, :isr if name.match? ISR

      :otros
    end

    def self.retained_or(name, retained, own)
      return retained if name.match? RETAINED

      own
    end
  end
end
