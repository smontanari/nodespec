require 'nodespec/connection_adapters/winrm_connection'

shared_examples 'valid_winrm_connection' do |hostname, options|
  before do
    allow(NodeSpec::ConnectionAdapters::WinrmConnection).to receive(:new).with(
      hostname, options
    ).and_return('winrmconnection')
  end
  it 'returns the new winrm connection' do
    expect(subject.connection).to eq('winrmconnection')
  end
end
