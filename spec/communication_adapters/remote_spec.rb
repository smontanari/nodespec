require 'nodespec/communication_adapters/remote'

module NodeSpec
  module CommunicationAdapters
    describe Remote do
      let(:subject) {
        Object.new.tap do |obj|
          obj.extend Remote
          def obj.session
            'session'
          end
        end
      }

      context 'no os' do
        it 'returns Ssh as default backend' do
          expect(subject.backend).to eq(Backends::Ssh)
        end

        it 'returns Ssh as backend proxy' do
          expect(subject.backend_proxy).to be_a(BackendProxy::Ssh)
        end
      end

      context 'UN*X os' do
        it 'returns Ssh for un*x OS' do
          expect(subject.backend('CentOS')).to eq(Backends::Ssh)
        end

        it 'returns Ssh as backend proxy' do
          expect(subject.backend_proxy).to be_a(BackendProxy::Ssh)
        end
      end

      context 'Windows os' do
        it 'returns Winrm for Windows OS' do
          expect(subject.backend('Windows')).to eq(Backends::WinRM)
        end

        it 'returns Ssh as backend proxy' do
          expect(subject.backend_proxy('Windows')).to be_a(BackendProxy::WinRM)
        end
      end
    end
  end
end
