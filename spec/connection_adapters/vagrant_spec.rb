require 'spec_helper'
require 'nodespec/connection_adapters/vagrant'

module NodeSpec
  module Adapters
    describe Vagrant do
      [['test_vm'], ['test_node', {'vm_name' => 'test_vm'}]].each do |args|
        describe "initialization" do
          let(:cmd_status) { double('status') }

          before(:each) do
            expect(Open3).to receive(:capture2e).with('vagrant --machine-readable ssh-config test_vm').and_return([cmd_output, cmd_status])
          end

          context 'vm not running' do
            let(:cmd_output) {
              '1402310908,,error-exit,Vagrant::Errors::SSHNotReady,The provider...'
            }

            it 'raises an error' do
              allow(cmd_status).to receive(:success?).and_return(false)

              expect {Vagrant.new(*args)}.to raise_error 'Vagrant::Errors::SSHNotReady,The provider...'
            end
          end

          context 'vm running' do
            let(:cmd_output) {
              <<-EOS
Host test_vm
  HostName test.host.name
  User testuser
  Port 1234
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /test/path/private_key
  IdentitiesOnly yes
  LogLevel FATAL
EOS
            }

            include_examples 'valid_ssh_connection', 'test.host.name', 'testuser', {port: 1234, keys: '/test/path/private_key'} do
              let(:subject) {subject = Vagrant.new(*args)}
              before do
                allow(cmd_status).to receive(:success?).and_return(true)
              end
            end
          end
        end
      end
    end
  end
end