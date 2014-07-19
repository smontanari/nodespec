require 'spec_helper'
require 'nodespec/communication_adapters/winrm'

module NodeSpec
  module CommunicationAdapters
    describe Winrm do
      context 'host name from the node name' do
        let(:subject) {Winrm.new('test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_communicator', 'test.host.name', {'foo' => 'bar'}
      end

      context 'host name from the options' do
        let(:subject) {Winrm.new('test_node', 'host' => 'test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_communicator', 'test.host.name', {'foo' => 'bar'}
      end
    end
  end
end
