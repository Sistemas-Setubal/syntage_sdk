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
      expect(described_class.parse(determination).keys).to eq described_class::EMPTY.keys
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

    context 'when the document declares the profit coefficient' do
      let(:coefficient) { <<~TEXT }
        COEFICIENTE DE UTILIDAD DEL EJERCICIO                             0.0345
      TEXT

      it 'keeps the coefficient as a decimal' do
        expect(described_class.parse(coefficient)[:profit_coefficient]).to eql 0.0345
      end
    end

    context 'when the coefficient base lives in an indented block' do
      let(:base) { <<~TEXT }
                                                    DATOS ADICIONALES

        COEFICIENTE DE UTILIDAD DEL EJERCICIO                             0.0000


           TOTAL DE INGRESOS ACUMULABLES                             127,504,359


           AJUSTE ANUAL POR INFLACIÓN                                    134,020
           ACUMULABLE


           INGRESOS NOMINALES PARA COEFICIENTE                      127,370,339
           DE UTILIDAD


           PÉRDIDA FISCAL PARA COEFICIENTE DE                           972,804
           UTILIDAD
      TEXT

      it 'reads the nominal income of the indented concept' do
        expect(described_class.parse(base)[:nominal_income_for_coefficient]).to eq 127_370_339
      end

      it 'reads the inflation adjustment of the indented concept' do
        expect(described_class.parse(base)[:inflation_adjustment]).to eq 134_020
      end

      it 'reads the tax loss used for the coefficient' do
        expect(described_class.parse(base)[:tax_loss_for_coefficient]).to eq 972_804
      end

      it 'still ignores the indented copy of a top level concept' do
        expect(described_class.parse(base)[:accruable_income]).to be_nil
      end
    end

    context 'when the coefficient authorization is answered' do
      let(:denied) { <<~TEXT }
        ¿TE AUTORIZARON APLICAR UN                NO
        COEFICIENTE DE UTILIDAD MENOR EN
        PAGOS PROVISIONALES AL DETERMINADO
        EN EL EJERCICIO?
      TEXT

      let(:granted) { <<~TEXT }
        ¿TE AUTORIZARON APLICAR UN                SÍ
        COEFICIENTE DE UTILIDAD MENOR EN
        PAGOS PROVISIONALES AL DETERMINADO
        EN EL EJERCICIO?
      TEXT

      let(:unrelated) { <<~TEXT }
        ¿ESTÁS OBLIGADO A CALCULAR Y PAGAR        NO
        PTU DEL EJERCICIO QUE DECLARA?
      TEXT

      it 'reads a negative answer as false' do
        expect(described_class.parse(denied)[:lower_coefficient_authorized]).to be false
      end

      it 'reads an affirmative answer as true' do
        expect(described_class.parse(granted)[:lower_coefficient_authorized]).to be true
      end

      it 'ignores a question the transcript asks about something else' do
        expect(described_class.parse(unrelated)[:lower_coefficient_authorized]).to be_nil
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
