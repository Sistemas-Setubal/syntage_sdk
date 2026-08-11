# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::Transcript do
  let(:determination) { <<~TEXT }
                                                    DETERMINACIÓN

    TOTAL DE INGRESOS ACUMULABLES                               4,111,834


    TOTAL DE DEDUCCIONES AUTORIZADAS                            4,623,656


    PÉRDIDA FISCAL DEL EJERCICIO                                  511,822


    RESULTADO FISCAL                                                    0
  TEXT

  describe '.parse' do
    it 'reads a concept written at the start of the line' do
      expect(described_class.parse(determination)[:accruable_income]).to eq 4_111_834
    end

    it 'strips the thousands separators' do
      expect(described_class.parse(determination)[:authorized_deductions]).to eq 4_623_656
    end

    it 'reads a concept whose amount is zero' do
      expect(described_class.parse(determination)[:taxable_result]).to eq 0
    end

    it 'returns nil for a concept that is not in the document' do
      expect(described_class.parse(determination)[:isr_payable]).to be_nil
    end

    it 'returns every field as nil for an empty document' do
      expect(described_class.parse('')).to eq described_class::EMPTY
    end

    it 'always answers with the full set of fields' do
      expect(described_class.parse(determination).keys).to eq described_class::FIELDS.values
    end

    context 'when the label is split across two lines' do
      let(:wrapped) { <<~TEXT }
        IMPUESTO SOBRE LA RENTA DEL                                          123
        EJERCICIO
      TEXT

      it 'joins the continuation line to resolve the concept' do
        expect(described_class.parse(wrapped)[:isr_for_year]).to eq 123
      end
    end

    context 'when an indented sub-block repeats a concept name' do
      let(:nested) { <<~TEXT }
        TOTAL DE DEDUCCIONES AUTORIZADAS                            4,623,656

                                                    DEDUCCIONES AUTORIZADAS
          TOTAL DE DEDUCCIONES AUTORIZADAS                                  7
      TEXT

      it 'ignores the indented copy and keeps the top level amount' do
        expect(described_class.parse(nested)[:authorized_deductions]).to eq 4_623_656
      end
    end

    context 'when the document repeats a concept across pages' do
      let(:repeated) { <<~TEXT }
        RESULTADO FISCAL                                                  915

                                                                Hoja 15 de 27
        RESULTADO FISCAL                                                    0
      TEXT

      it 'keeps the first occurrence' do
        expect(described_class.parse(repeated)[:taxable_result]).to eq 915
      end
    end

    context 'when the page header carries a date' do
      let(:header) { <<~TEXT }
        Vencimiento obligación:                  31/03/2026
        RESULTADO FISCAL                                  42
      TEXT

      it 'does not mistake the date for an amount' do
        expect(described_class.parse(header)[:taxable_result]).to eq 42
      end
    end

    context 'when an amount has decimals' do
      let(:decimals) { <<~TEXT }
        PAGOS PROVISIONALES EFECTUADOS                          1,234.56
      TEXT

      it 'keeps the fractional part' do
        expect(described_class.parse(decimals)[:provisional_payments]).to eq 1234.56
      end
    end
  end
end
