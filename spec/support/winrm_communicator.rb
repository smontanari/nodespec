require 'nodespec/communication_adapters/winrm_communicator'

shared_examples 'valid_winrm_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::WinrmCommunicator).to receive(:new).with(
      hostname, options
    ).and_return('winrmconnection')
  end
  it 'returns the new winrm connection' do
    expect(subject.connection).to eq('winrmconnection')
  end
end
