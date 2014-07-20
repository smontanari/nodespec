require 'spec_helper'
require 'nodespec/provisioning/ansible'

module NodeSpec
  module Provisioning
    describe Ansible, init_with_current_node: true do
      shared_context 'create temp file' do |prefix, path, content|
        let(:tmp_file) {double('temp file')}
        before do
          allow(Tempfile).to receive(:new).with(prefix).and_return(tmp_file)
          allow(tmp_file).to receive(:path).and_return(path)
          expect(tmp_file).to receive(:write).ordered.with(content)
          expect(tmp_file).to receive(:flush).ordered
          expect(tmp_file).to receive(:close!).ordered
        end
      end
      before do
        allow(current_node).to receive(:name).and_return('test_host')
        allow(current_node).to receive_message_chain(:communicator, :session, :options).and_return({
          user: 'test_user',
          keys: 'path/to user/key'
        })
      end

      describe 'executing an ansible playbook' do
        it_executes_the_local_command('ansible-playbook /path\ to/playbook -l test_host -u test_user --private-key=path/to\ user/key --sudo --opt1 --opt2') do
          ansible_execute_playbook '/path to/playbook', %w[--opt1 --opt2]
        end

        describe 'setting playbook variables' do
          it_executes_the_local_command(/^ansible-playbook .* -e '\{"pacman":"mrs","ghosts":\["inky","pinky","clyde","sue"\]\}'$/) do
            set_extra_vars pacman: 'mrs', ghosts: %w[inky pinky clyde sue]
            ansible_execute_playbook '/path to/playbook'
          end
        end
      end

      describe 'executing an ansible module' do
        before do
          allow(current_node).to receive_message_chain(:communicator, :session, :transport, :host).and_return('test.host')
          allow(current_node).to receive_message_chain(:communicator, :session, :transport, :port).and_return(1234)
          
        end

        it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u test_user --private-key=path/to\ user/key --sudo --opt1 --opt2') do
          ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
        end

        describe 'running ansible' do
          context 'multiples keys' do
            before do
              allow(current_node).to receive_message_chain(:communicator, :session, :options).and_return({
                user: 'test_user',
                keys: ['path/to user/key1', 'path/to user/key2']
              })
            end
            it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u test_user --private-key=path/to\ user/key1,path/to\ user/key2 --sudo --opt1 --opt2') do
              ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
            end
          end

          context 'disable sudo' do
            it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u test_user --private-key=path/to\ user/key --opt1 --opt2') do
              run_as_sudo(false)
              ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
            end
          end

          context 'enable sudo' do
            it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u test_user --private-key=path/to\ user/key --sudo --opt1 --opt2') do
              run_as_sudo
              ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
            end
          end

          context 'runs as root without sudo' do
            before do
              allow(current_node).to receive_message_chain(:communicator, :session, :options).and_return({
                user: 'root',
                keys: 'path/to user/key'
              })
            end
            it_executes_the_local_command('ansible test_host -m module -a module\ arguments -u root --private-key=path/to\ user/key --opt1 --opt2') do
              ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
            end
          end
        end

        describe 'setting a path to an inventory' do
          it_executes_the_local_command(/^ansible test_host .* -i path\/to\\ custom\/hosts .*/) do
            set_hostfile_path 'path/to custom/hosts'
            ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
          end

          describe 'enabling inventory host auto detection' do
            context 'no groups specified' do
              include_context 'create temp file', 'nodespec_ansible_hosts', '/path/to/inventory', /test_host ansible_ssh_host=test.host ansible_ssh_port=1234/

              it_executes_the_local_command(/^ansible test_host .* -i \/path\/to\/inventory .*/) do
                enable_host_auto_discovery
                ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
              end
            end
  
            context 'group specified' do
              include_context 'create temp file', 'nodespec_ansible_hosts', '/path/to/inventory', <<-eos
[test-group]
test_host ansible_ssh_host=test.host ansible_ssh_port=1234
eos

              it_executes_the_local_command(/^ansible test_host .* -i \/path\/to\/inventory .*/) do
                enable_host_auto_discovery('test-group')
                ansible_execute_module 'module', 'module arguments', %w[--opt1 --opt2]
              end
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
            include_context 'create temp file', 'nodespec_ansible_cfg', '/path/to/cfg', 'test config'

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