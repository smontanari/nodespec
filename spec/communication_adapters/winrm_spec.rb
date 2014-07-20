require 'spec_helper'
require 'nodespec/communication_adapters/winrm'

module NodeSpec
  module CommunicationAdapters
    describe Winrm do
      include_context 'new_winrm_communicator', 'test.host.name', 'test_os', {'foo' => 'bar'}

      it 'returns communicator with the host name from the node name' do
        expect(Winrm.communicator_for('test.host.name', 'test_os', 'foo' => 'bar')).to eq('winrm communicator')
      end

      it 'returns communicator with the host name from the options' do
        expect(Winrm.communicator_for('test_node', 'test_os', 'host' => 'test.host.name', 'foo' => 'bar')).to eq('winrm communicator')
      end
    end
  end
end
