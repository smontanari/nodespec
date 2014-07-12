require 'nodespec/connection_adapters/winrm'

module NodeSpec
  module ConnectionAdapters
    describe Winrm do
      shared_examples 'valid_winrm_connection' do |endpoint, transport, options|
        before do
          allow(NodeSpec::ConnectionAdapters::WinrmConnection).to receive(:new).with(
            endpoint, transport, options
          ).and_return('winrmconnection')
        end
        it 'returns the new winrm connection' do
          expect(subject.connection).to eq('winrmconnection')
        end
      end

      context 'host name from the node name, default port and transport' do
        let(:subject) {Winrm.new('test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', "http://test.host.name:5985/wsman", :plaintext, {'foo' => 'bar', disable_sspi: true}
      end

      context 'host name from the options, default port and transport' do
        let(:subject) {Winrm.new('test_node', 'host' => 'test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', "http://test.host.name:5985/wsman", :plaintext, {'foo' => 'bar', disable_sspi: true}
      end

      context 'host name from the node name, given port and transport' do
        let(:subject) {Winrm.new('test.host.name', 'port' => 1234, 'transport' => 'ssl', 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', "http://test.host.name:1234/wsman", :ssl, {'foo' => 'bar'}
      end

      context 'host name from the node name, given port and transport' do
        let(:subject) {Winrm.new('test.host.name', 'port' => 1234, 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', "http://test.host.name:1234/wsman", :plaintext, {'foo' => 'bar', disable_sspi: true}
      end
    end
  end
end
