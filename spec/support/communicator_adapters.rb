shared_context 'new_ssh_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::SshCommunicator).to receive(:new).with(hostname, options).and_return('ssh communicator')
  end
end

shared_context 'new_winrm_communicator' do |hostname, options|
  before do
    allow(NodeSpec::CommunicationAdapters::WinrmCommunicator).to receive(:new).with(hostname, options).and_return('winrm communicator')
  end
end

shared_examples 'new_communicator' do |adapter_clazz, connection|
  include_context "new_#{connection}_communicator", 'test.host.name', 'foo' => 'bar'

  it 'returns communicator with the host name from the node name' do
    expect(adapter_clazz.communicator_for('test.host.name', 'foo' => 'bar')).to eq("#{connection} communicator")
  end

  it 'returns communicator with the host name from the options' do
    expect(adapter_clazz.communicator_for('test_node', 'host' => 'test.host.name', 'foo' => 'bar')).to eq("#{connection} communicator")
  end
end