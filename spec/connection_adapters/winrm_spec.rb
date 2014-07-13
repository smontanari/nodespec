require 'spec_helper'
require 'nodespec/connection_adapters/winrm'

module NodeSpec
  module ConnectionAdapters
    describe Winrm do
      context 'host name from the node name' do
        let(:subject) {Winrm.new('test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', 'test.host.name', {'foo' => 'bar'}
      end

      context 'host name from the options' do
        let(:subject) {Winrm.new('test_node', 'host' => 'test.host.name', 'foo' => 'bar')}
        include_examples 'valid_winrm_connection', 'test.host.name', {'foo' => 'bar'}
      end
    end
  end
end
