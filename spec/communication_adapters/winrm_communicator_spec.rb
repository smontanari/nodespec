require 'spec_helper'
require 'nodespec/communication_adapters/winrm_communicator'

module NodeSpec
  module CommunicationAdapters
    describe WinrmCommunicator do
      let(:configuration) {double('configuration')}

      shared_context 'creating new session' do |hostname, port, transport, options|
        before do
          expect(configuration).to receive(:unbind_ssh_session)
          allow(WinRM::WinRMWebService).to receive(:new).with("http://#{hostname}:#{port}/wsman", transport, options).and_return('session')
          allow(configuration).to receive(:bind_winrm_session_for) do |host, endpoint, &block|
            expect(host).to eq hostname
            expect(endpoint).to eq "http://#{hostname}:#{port}/wsman"
            block.call
          end
        end
      end

      shared_examples 'binding session' do
        it 'returns a session' do
          subject.bind_to(configuration)

          expect(subject.session).to eq('session')
        end
      end

      describe 'binding the session' do
        context 'default port and transport' do
          subject {WinrmCommunicator.new('test.host.name', 'foo' => 'bar')}
          include_context 'creating new session', 'test.host.name', 5985, :plaintext, {foo: 'bar', disable_sspi: true}
          include_examples 'binding session'
        end

        context 'custom port and transport' do
          subject {WinrmCommunicator.new('test.host.name', 'port' => 1234, 'transport' => 'test_transport', 'foo' => 'bar')}
          include_context 'creating new session', 'test.host.name', 1234, :test_transport, {foo: 'bar'}
          include_examples 'binding session'
        end

        context 'same session' do
          subject {WinrmCommunicator.new('test.host.name', 'foo' => 'bar')}
          before do
            expect(configuration).to receive(:unbind_ssh_session)
            allow(configuration).to receive(:bind_winrm_session_for).with('test.host.name', "http://test.host.name:5985/wsman").and_return('session')
          end

          include_examples 'binding session'
        end
      end

      describe 'providing backend proxy' do
        subject {WinrmCommunicator.new('test.host.name')}
        include_examples 'providing a backend', :winrm, BackendProxy::Winrm
      end
    end
  end
end