shared_examples 'new_ssh_communicator' do |hostname, os, options|
  before do
    allow(NodeSpec::CommunicationAdapters::SshCommunicator).to receive(:new).with(
      hostname, os, options
    ).and_return('ssh communicator')
  end
end