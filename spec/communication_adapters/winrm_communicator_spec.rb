require 'winrm'
require 'nodespec/communication_adapters/winrm_communicator'

module NodeSpec
  module CommunicationAdapters
    describe WinrmCommunicator do
      let(:rspec_configuration) {double('rspec configuration')}
      shared_examples 'creating new session' do |hostname, port, transport, options|
        before do
          allow(WinRM::WinRMWebService).to receive(:new).with("http://#{hostname}:#{port}/wsman", transport, options).and_return('new session')
          expect(rspec_configuration).to receive(:winrm=).with('new session')
          expect(rspec_configuration).to receive(:host=).with(hostname)
        end

        it 'creates and holds a new session' do
          subject.bind_to(rspec_configuration)

          expect(subject.session).to eq('new session')
        end
      end

      describe 'connecting to the web service' do
        before do
          allow(rspec_configuration).to receive(:ssh)
          allow(rspec_configuration).to receive(:winrm).and_return(nil)
        end

        context 'default port and transport' do
          let(:subject) {WinrmCommunicator.new('test.host.name', nil, 'foo' => 'bar')}
          include_examples 'creating new session', 'test.host.name', 5985, :plaintext, {foo: 'bar', disable_sspi: true}
        end

        context 'custom port and transport' do
          let(:subject) {WinrmCommunicator.new('test.host.name', nil, 'port' => 1234, 'transport' => 'test_transport', 'foo' => 'bar')}
          include_examples 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar'}
        end
      end

      describe 'binding to configuration' do
        let(:winrm_session) {double('winrm session')}
        let(:subject) { WinrmCommunicator.new(
          'test.host.name', nil, 'port' => 1234, 'transport' => 'test_transport', foo: 'bar', 'baz' => 'quaz')
        }

        before do
          allow(rspec_configuration).to receive(:ssh)
        end

        shared_context 'existing session' do |endpoint|
          before do
            allow(rspec_configuration).to receive(:winrm).and_return(winrm_session)
            allow(winrm_session).to receive(:endpoint).and_return(endpoint)
          end
        end

        context 'existing ssh session' do
          let(:ssh_session) {double('ssh session')}
          before do
            allow(rspec_configuration).to receive(:ssh).and_return(ssh_session)
            allow(rspec_configuration).to receive(:winrm).and_return(nil)
            allow(ssh_session).to receive(:host)
            allow(ssh_session).to receive(:options).and_return({})
            expect(ssh_session).to receive(:close)
            expect(rspec_configuration).to receive(:ssh=).with(nil)
          end

          include_examples 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar', baz: 'quaz'}
        end

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
            expect(rspec_configuration).not_to receive(:host=)

            subject.bind_to(rspec_configuration)

            expect(subject.session).to eq(winrm_session)
          end
        end
      end

      describe 'providing backend proxy' do
        subject {WinrmCommunicator.new('test.host.name')}
        include_examples 'providing a backend', :winrm, BackendProxy::Winrm
      end

      describe '#initialize' do
        [nil, 'Test OS'].each do |os|
          it 'holds the os information' do
            expect(WinrmCommunicator.new('test.host.name', os, {}).os).to eq os
          end
        end
      end
    end
  end
end