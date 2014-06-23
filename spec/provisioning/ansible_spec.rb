require 'spec_helper'
require 'nodespec/provisioning/ansible'

module NodeSpec
  module Provisioning
    describe Ansible, init_with_current_node: true do
      describe 'executing an ansible module' do
        before do
          current_node.stub(name: 'test_host')
          current_node.stub_chain(:remote_connection, :session, :options).and_return({
            user: 'test_user',
            keys: 'path/to user/key'
          })
        end

        describe 'running ansible' do
          it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u test_user --private-key=path/to\ user/key --opt1 --opt2') do
            ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
          end
        end

        describe 'running ansible-playbook' do
          it_executes_the_local_command('ansible-playbook /path\ to/playbook -l test_host -u test_user --private-key=path/to\ user/key --opt1 --opt2') do
            ansible_execute_playbook '/path to/playbook', %w[--opt1 --opt2]
          end
        end

        describe 'setting the inventory' do
          it_executes_the_local_command(/ansible test_host .* -i path\/to\\ custom\/hosts .*/) do
            set_hostfile_path 'path/to custom/hosts'
            ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
          end

          describe 'inline custom inventory' do
            let(:inventory_file) {double('inventory file')}
            before do
              Tempfile.stub(:new).with('nodespec_ansible_hosts').and_return(inventory_file)
              allow(inventory_file).to receive(:path).and_return('/path/to/inventory')
              allow(inventory_file).to receive(:flush)
              expect(inventory_file).to receive(:write).with('test inventory')
            end

            it_executes_the_local_command(/ansible test_host .* -i \/path\/to\/inventory .*/) do
              ansible_inventory 'test inventory'
              ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
            end
          end
        end

        describe 'configuring ansible' do
          it_executes_the_local_command(/^ANSIBLE_HOST_KEY_CHECKING=False ansible .*/) do
            set_host_key_checking(false)
            ansible_execute_module 'module', 'module arguments'
          end

          it_executes_the_local_command(/^ANSIBLE_CONFIG=\/path\\ to\/config ANSIBLE_HOST_KEY_CHECKING=False ansible .*/) do
            set_config_path('/path to/config')
            set_host_key_checking(false)
            ansible_execute_module 'module', 'module arguments'
          end

          describe 'inline custom configuration' do
            let(:cfg_file) {double('config file')}
            before do
              Tempfile.stub(:new).with('nodespec_ansible_cfg').and_return(cfg_file)
              allow(cfg_file).to receive(:path).and_return('/path/to/cfg')
              allow(cfg_file).to receive(:flush)
              expect(cfg_file).to receive(:write).with('test config')
            end

            it_executes_the_local_command(/^ANSIBLE_CONFIG=\/path\/to\/cfg ansible .*/) do
              ansible_config('test config')
              ansible_execute_module 'module', 'module arguments'
            end
          end
        end
      end
    end
  end
end