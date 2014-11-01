require 'spec_helper'
require 'nodespec/communication_adapters/native_communicator'

module NodeSpec
  module CommunicationAdapters
    describe NativeCommunicator do
      describe 'providing backend proxy' do
        context 'non Windows os' do
          before do
            allow(OS).to receive(:windows?).and_return(false)
          end
          include_examples 'providing a backend', :exec, BackendProxy::Exec
        end

        context 'Windows os' do
          before do
            allow(OS).to receive(:windows?).and_return(true)
          end

          include_examples 'providing a backend', :cmd, BackendProxy::Cmd
        end
      end

      describe '#init_session' do
        let(:configuration) {double('configuration')}

        it 'unbinds other sessions' do
          expect(configuration).to receive(:unbind_ssh_session)
          expect(configuration).to receive(:unbind_winrm_session)
          subject.init_session(configuration)
        end
      end
    end
  end
end