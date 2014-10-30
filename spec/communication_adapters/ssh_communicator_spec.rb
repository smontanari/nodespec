require 'spec_helper'
require 'nodespec/communication_adapters/ssh_communicator'

module NodeSpec
  module CommunicationAdapters
    describe SshCommunicator do
      let(:configuration) {double('configuration')}

      shared_context 'creating new session' do |hostname, options|
        before do
          expect(configuration).to receive(:unbind_winrm_session)
          allow(Net::SSH).to receive(:start).with(hostname, 'testuser', options).and_return('session')
          allow(configuration).to receive(:bind_ssh_session_for) do |host, port, &block|
            expect(host).to eq hostname
            expect(port).to eq port
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
        context 'default options' do
          subject {SshCommunicator.new('test.host.name')}
          before do
            allow(Net::SSH).to receive(:configuration_for).and_return({someoption: 'somevalue', user: 'testuser'})
          end
          include_context 'creating new session', 'test.host.name', someoption: 'somevalue', user: 'testuser'
          include_examples 'binding session'
        end

        context 'custom options' do
          subject {SshCommunicator.new('test.host.name', 'port' => 1234, 'user' => 'testuser', 'password' => 'testpassword', 'keys' => 'testkeys')}
          before do
            allow(Net::SSH).to receive(:configuration_for).and_return({someoption: 'somevalue', port: 22, user: 'testuser'})
          end
          include_context 'creating new session', 'test.host.name', someoption: 'somevalue', port: 1234, user: 'testuser', password: 'testpassword', keys: 'testkeys'
          include_examples 'binding session'
        end

        context 'same session' do
          subject {SshCommunicator.new('test.host.name', 'port' => 1234, 'user' => 'testuser')}
          before do
            expect(configuration).to receive(:unbind_winrm_session)
            allow(configuration).to receive(:bind_ssh_session_for).with('test.host.name', 1234).and_return('session')
          end

          include_examples 'binding session'
        end
      end

      describe 'providing backend proxy' do
        subject {SshCommunicator.new('test.host.name')}
        include_examples 'providing a backend', :ssh, BackendProxy::Ssh
      end
    end
  end
end