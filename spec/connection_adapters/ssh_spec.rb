require 'spec_helper'
require 'nodespec/connection_adapters/ssh'

module NodeSpec
  module Adapters
    describe Ssh do
      before do
        Net::SSH.stub(configuration_for: {})
      end

      context 'host name from the node description' do
        let(:subject) {Ssh.new('test.host.name', 'port' => 1234, 'username' => 'testuser', 'password' => 'testpassword')}
        include_examples 'valid_ssh_connection', 'test.host.name', 'testuser', {port: 1234, password: 'testpassword'}
      end

      context 'host name from the options' do
        let(:subject) {Ssh.new('test_node', 'host' => 'test.host.name', 'port' => 1234, 'username' => 'testuser', 'keys' => '/path/to/key')}
        include_examples 'valid_ssh_connection', 'test.host.name', 'testuser', {port: 1234, keys: '/path/to/key'}
      end

      context 'credentials from OpenSSH config files' do
        let(:subject) {Ssh.new('test_node', 'host' => 'test.host.name', 'port' => 1234)}
        before do
          allow(Net::SSH).to receive(:configuration_for).with('test.host.name').and_return(user: 'testuser', keys: '/path/to/key')
        end
        include_examples 'valid_ssh_connection', 'test.host.name', 'testuser', {user: 'testuser', port: 1234, keys: '/path/to/key'}
      end
    end
  end
end
