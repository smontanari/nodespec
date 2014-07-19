require 'nodespec/communication_adapters/ssh_communicator'

shared_examples 'valid_ssh_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::SshCommunicator).to receive(:new).with(hostname, options).and_return('sshconnection')
  end
  it 'returns the new ssh connection' do
    expect(subject.connection).to eq('sshconnection')
  end
end