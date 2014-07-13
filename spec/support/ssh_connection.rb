require 'nodespec/connection_adapters/ssh_connection'

shared_examples 'valid_ssh_connection' do |hostname, options|
  before do
    allow(NodeSpec::ConnectionAdapters::SshConnection).to receive(:new).with(hostname, options).and_return('sshconnection')
  end
  it 'returns the new ssh connection' do
    expect(subject.connection).to eq('sshconnection')
  end
end