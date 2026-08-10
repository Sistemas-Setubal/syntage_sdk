# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::ConceptBucket do
  describe '.for' do
    it 'buckets the taxpayer own income tax' do
      expect(described_class.for('ISR personas morales')).to eq(:isr)
    end

    it 'buckets income tax withheld from third parties' do
      expect(described_class.for('ISR retenciones por salarios')).to eq(:isr_retenciones)
    end

    it 'buckets income tax paid on behalf of third parties' do
      expect(described_class.for('ISR POR PAGOS POR CUENTA DE TERCEROS')).to eq(:isr_retenciones)
    end

    it 'buckets the taxpayer own value added tax' do
      expect(described_class.for('Impuesto al Valor Agregado. Personas morales')).to eq(:iva)
    end

    it 'buckets value added tax withheld' do
      expect(described_class.for('IVA retenciones')).to eq(:iva_retenciones)
    end

    it 'falls back to the catch-all bucket' do
      expect(described_class.for('ESTADOS FINANCIEROS')).to eq(:otros)
    end
  end
end
