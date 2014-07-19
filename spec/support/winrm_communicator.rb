require 'nodespec/communication_adapters/winrm_communicator'

shared_examples 'valid_winrm_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::WinrmCommunicator).to receive(:new).with(
      hostname, options
    ).and_return('winrm communicator')
  end
  it 'returns the new winrm connection' do
    expect(subject.communicator).to eq('winrm communicator')
  end
end
