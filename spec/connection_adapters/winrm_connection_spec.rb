require 'winrm'
require 'nodespec/connection_adapters/winrm_connection'

module NodeSpec
  module ConnectionAdapters
    describe WinrmConnection do
      let(:rspec_configuration) {double('rspec configuration')}
      shared_examples 'creating new session' do |hostname, port, transport, options|
        before do
          allow(WinRM::WinRMWebService).to receive(:new).with("http://#{hostname}:#{port}/wsman", transport, options).and_return('new session')
          expect(rspec_configuration).to receive(:winrm=).with('new session')
        end

        it 'creates and holds a new session' do
          subject.bind_to(rspec_configuration)

          expect(subject.session).to eq('new session')
        end
      end

      describe 'connecting to the web service' do
        before do
          allow(rspec_configuration).to receive(:winrm).and_return(nil)
        end

        context 'default port and transport' do
          let(:subject) {WinrmConnection.new('test.host.name', 'foo' => 'bar')}
          include_examples 'creating new session', 'test.host.name', 5985, :plaintext, {foo: 'bar', disable_sspi: true}
        end

        context 'custom port and transport' do
          let(:subject) {WinrmConnection.new('test.host.name', 'port' => 1234, 'transport' => 'test_transport', 'foo' => 'bar')}
          include_examples 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar'}
        end
      end

      describe 'binding to configuration' do
        let(:winrm_session) {double('winrm session')}
        let(:subject) { WinrmConnection.new(
          'test.host.name', 'port' => 1234, 'transport' => 'test_transport', foo: 'bar', 'baz' => 'quaz')
        }

        shared_context 'existing session' do |endpoint|
          before do
            allow(rspec_configuration).to receive(:winrm).and_return(winrm_session)
            allow(winrm_session).to receive(:endpoint).and_return(endpoint)
          end
        end

        describe '#bind_to' do
          context 'no existing session' do
            before do
              allow(rspec_configuration).to receive(:winrm).and_return(nil)
            end

            include_examples 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar', baz: 'quaz'}
          end

          context 'existing session with different endpoint' do
            include_context 'existing session', 'http://test.another.host.name:1234/wsman'
            include_examples 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar', baz: 'quaz'}
          end

          context 'existing session with same connection' do
            include_context 'existing session', "http://test.host.name:1234/wsman"

            it 'does not change the current rspec configuration' do
              expect(WinRM::WinRMWebService).not_to receive(:new)
              expect(rspec_configuration).not_to receive(:winrm=)
        
              subject.bind_to(rspec_configuration)

              expect(subject.session).to eq(winrm_session)
            end
          end
        end
      end

      it 'is a Remote connection' do
        expect(WinrmConnection.new('test.host.name', {})).to be_a(Remote)
      end
    end
  end
end