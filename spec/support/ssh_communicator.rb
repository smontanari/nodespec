require 'nodespec/communication_adapters/ssh_communicator'

shared_examples 'valid_ssh_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::SshCommunicator).to receive(:new).with(hostname, options).and_return('ssh communicator')
  end
  it 'returns the new ssh communicator' do
    expect(subject.communicator).to eq('ssh communicator')
  end
end