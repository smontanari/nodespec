require 'nodespec/ssh_connection'

shared_examples 'valid_ssh_connection' do |options|
  before do
    allow(NodeSpec::SshConnection).to receive(:new).with(options).and_return('sshconnection')
  end
  it 'returns the new ssh connection' do
    expect(subject.connection).to eq('sshconnection')
  end
end