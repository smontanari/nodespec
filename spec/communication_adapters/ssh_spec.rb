require 'spec_helper'
require 'nodespec/communication_adapters/ssh'

module NodeSpec
  module CommunicationAdapters
    describe Ssh do
      include_context 'new_ssh_communicator', 'test.host.name', 'test_os', {'foo' => 'bar'}

      it 'returns communicator with the host name from the node name' do
        expect(Ssh.communicator_for('test.host.name', 'test_os', 'foo' => 'bar')).to eq('ssh communicator')
      end

      it 'returns communicator with the host name from the options' do
        expect(Ssh.communicator_for('test_node', 'test_os', 'host' => 'test.host.name', 'foo' => 'bar')).to eq('ssh communicator')
      end
    end
  end
end
