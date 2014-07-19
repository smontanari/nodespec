require 'spec_helper'
require 'nodespec/communication_adapters/ssh'

module NodeSpec
  module CommunicationAdapters
    describe Ssh do
      context 'host name from the node name' do
        let(:subject) {Ssh.new('test.host.name', 'foo' => 'bar')}
        include_examples 'valid_ssh_communicator', 'test.host.name', {'foo' => 'bar'}
      end

      context 'host name from the options' do
        let(:subject) {Ssh.new('test_node', 'host' => 'test.host.name', 'foo' => 'bar')}
        include_examples 'valid_ssh_communicator', 'test.host.name', {'foo' => 'bar'}
      end
    end
  end
end
