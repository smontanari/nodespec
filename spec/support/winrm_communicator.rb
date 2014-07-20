require 'nodespec/communication_adapters/winrm_communicator'

shared_context 'new_winrm_communicator' do |hostname, os, options|
  before do
    allow(NodeSpec::CommunicationAdapters::WinrmCommunicator).to receive(:new).with(
      hostname, os, options
    ).and_return('winrm communicator')
  end
end
