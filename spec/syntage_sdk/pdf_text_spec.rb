# frozen_string_literal: true

require 'syntage_sdk'

RSpec.describe SyntageSdk::PdfText do
  let(:status) { instance_double Process::Status, success?: true }

  before { allow(Open3).to receive(:capture3).and_return ['DECLARACIÓN', '', status] }

  describe '.extract' do
    it 'runs the layout preserving conversion' do
      described_class.extract 'bytes'

      expect(Open3).to have_received(:capture3).with('pdftotext', '-layout', anything, '-')
    end

    it 'converts the file it wrote with the given bytes' do
      written = nil
      allow(Open3).to receive(:capture3) do |*args|
        written = File.read args[2]
        ['', '', status]
      end
      described_class.extract 'bytes'

      expect(written).to eq('bytes')
    end

    it 'returns the extracted text' do
      expect(described_class.extract('bytes')).to eq('DECLARACIÓN')
    end

    it 'reads the binary path from the environment' do
      allow(ENV).to receive(:fetch).with('SYNTAGE_PDFTOTEXT', 'pdftotext').and_return '/opt/bin/pdftotext'
      described_class.extract 'bytes'

      expect(Open3).to have_received(:capture3).with('/opt/bin/pdftotext', anything, anything, anything)
    end

    it 'accepts an explicit binary' do
      described_class.extract 'bytes', binary: 'pdftotext-6'

      expect(Open3).to have_received(:capture3).with('pdftotext-6', anything, anything, anything)
    end

    it 'raises when the conversion fails' do
      allow(status).to receive(:success?).and_return false

      expect { described_class.extract 'bytes' }.to raise_error(SyntageSdk::DependencyError, /failed/)
    end

    it 'raises when the binary is not installed' do
      allow(Open3).to receive(:capture3).and_raise Errno::ENOENT

      expect { described_class.extract 'bytes' }.to raise_error(SyntageSdk::DependencyError, /not found/)
    end

    it 'removes the temporary file it created' do
      path = nil
      allow(Open3).to receive(:capture3) do |*args|
        path = args[2]
        ['', '', status]
      end
      described_class.extract 'bytes'

      expect(File).not_to exist(path)
    end
  end
end
