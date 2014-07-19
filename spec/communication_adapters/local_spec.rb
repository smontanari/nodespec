require 'nodespec/communication_adapters/local'

module NodeSpec
  module CommunicationAdapters
    describe Local do
      let(:subject) {Object.new.extend Local}

      context 'no os' do
        it 'returns Exec as default backend' do
          expect(subject.backend).to eq(Backends::Exec)
        end

        it 'returns Exec as backend proxy' do
          expect(subject.backend_proxy).to be_a(BackendProxy::Exec)
        end
      end
      
      context 'UN*X os' do
        it 'returns Exec as backend' do
          expect(subject.backend('CentOS')).to eq(Backends::Exec)
        end

        it 'returns Exec as backend proxy' do
          expect(subject.backend_proxy('CentOS')).to be_a(BackendProxy::Exec)
        end
      end

      context 'Windows os' do
        it 'returns Cmd as backend' do
          expect(subject.backend('Windows')).to eq(Backends::Cmd)
        end

        it 'returns Exec as backend proxy' do
          expect(subject.backend_proxy('Windows')).to be_a(BackendProxy::Cmd)
        end
      end
    end
  end
end
