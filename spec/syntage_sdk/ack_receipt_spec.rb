# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::AckReceipt do
  let(:current_format) { <<~TEXT }
    Impuestos que declara:
    Concepto de pago 1:                 ISR personas morales
    A cargo:                                                     0
    Cantidad a cargo:                                            0
    Cantidad a pagar:                                            0
    Concepto de pago 2:                 Impuesto al Valor Agregado. Personas morales
    A favor:                                                   271
    Cantidad a cargo:                                            0
    Cantidad a pagar:                                            0
  TEXT

  let(:legacy_format) { <<~TEXT }
    Impuestos que declara:
                                        ISR POR PAGOS POR CUENTA DE TERCEROS O RETENCIONES POR
    Concepto de pago 1: 1
                                        ARRENDAMIENTO DE INMUEBLES
    Impuesto a cargo:                                        6,500
    Parte actualizada:                                           0
    Recargos:                                                    0
    Cantidad a cargo:                                        6,500
    Cantidad a pagar:                                        6,500
  TEXT

  let(:amended_format) { <<~TEXT }
    Impuestos que declara:
    Concepto de pago 1:                 Impuesto al Valor Agregado. Personas morales
    A cargo:                                                 3,145
    Parte actualizada:                                          45
    Recargos:                                                  234
    Fecha del pago realizado con anterioridad:          02/12/2024
    Monto pagado con anterioridad:                           4,188
    Cantidad a cargo:                                            0
    Cantidad a favor:                                          764
    Cantidad a pagar:                                            0
  TEXT

  describe '.parse' do
    it 'returns one entry per declared concept' do
      expect(described_class.parse(current_format).size).to eq(2)
    end

    it 'reads the whole concept' do
      expect(described_class.parse(current_format).first).to eq(
        name: 'ISR personas morales', bucket: :isr,
        a_cargo: 0, a_favor: nil, actualizacion: nil, recargos: nil,
        pagado_con_anterioridad: nil, cantidad_a_cargo: 0,
        cantidad_a_favor: nil, cantidad_a_pagar: 0
      )
    end

    it 'reads amounts declared in favour of the taxpayer' do
      expect(described_class.parse(current_format).last[:a_favor]).to eq(271)
    end

    it 'leaves fields absent from the receipt as nil' do
      expect(described_class.parse(current_format).last[:recargos]).to be_nil
    end

    it 'classifies the concept into a tax bucket' do
      expect(described_class.parse(current_format).last[:bucket]).to eq(:iva)
    end

    it 'rebuilds concept names wrapped around the legacy layout' do
      expect(described_class.parse(legacy_format).first[:name])
        .to eq('ISR POR PAGOS POR CUENTA DE TERCEROS O RETENCIONES POR ARRENDAMIENTO DE INMUEBLES')
    end

    it 'rebuilds names wrapped around a concept line with no number' do
      expect(described_class.parse("Impuestos que declara:\nConcepto de pago 1:\nIVA retenciones\n").first[:name])
        .to eq('IVA retenciones')
    end

    it 'strips thousand separators from amounts' do
      expect(described_class.parse(legacy_format).first[:a_cargo]).to eq(6500)
    end

    it 'maps the legacy surcharge field' do
      expect(described_class.parse(legacy_format).first[:recargos]).to eq(0)
    end

    it 'keeps decimals when the amount has cents' do
      expect(described_class.parse("Concepto de pago 1: IVA\nA cargo: 1,234.56\n").first[:a_cargo])
        .to eq(1234.56)
    end

    it 'parses concepts presented without amounts' do
      expect(described_class.parse("Concepto presentado 2: ESTADOS FINANCIEROS\n").first[:name])
        .to eq('ESTADOS FINANCIEROS')
    end

    it 'reads what an amended return already paid' do
      expect(described_class.parse(amended_format).first[:pagado_con_anterioridad]).to eq(4188)
    end

    it 'keeps the resulting credit apart from the determined one' do
      expect(described_class.parse(amended_format).first)
        .to include(a_favor: nil, cantidad_a_favor: 764)
    end

    it 'ignores dates that sit among the amounts' do
      expect(described_class.parse(amended_format).size).to eq(1)
    end

    it 'ignores amounts that appear before any concept' do
      expect(described_class.parse("A cargo: 500\n")).to be_empty
    end

    it 'returns no concepts for an empty document' do
      expect(described_class.parse(nil)).to be_empty
    end
  end
end
