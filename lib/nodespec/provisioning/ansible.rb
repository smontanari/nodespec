require 'shellwords'
require 'tempfile'
require 'nodespec/local_command_runner'

module NodeSpec
  module Provisioning
    class Ansible
      include LocalCommandRunner
      CUSTOM_CONFIG_FILENAME = 'nodespec_ansible_cfg'
      CUSTOM_INVENTORY_FILENAME = 'nodespec_ansible_hosts'

      def initialize(node)
        @node = node
        @cmd_prefix = []
      end

      def set_config_path(path)
        @cmd_prefix << "ANSIBLE_CONFIG=#{path.shellescape}"
      end

      def ansible_config(text)
        file = create_temp_file(CUSTOM_CONFIG_FILENAME, text)
        @cmd_prefix << "ANSIBLE_CONFIG=#{file.path.shellescape}"
      end

      def ansible_inventory(text)
        file = create_temp_file(CUSTOM_INVENTORY_FILENAME, text)
        @hostfile_option = "-i #{file.path.shellescape}"
      end

      def set_hostfile_path(path)
        @hostfile_option = "-i #{path.shellescape}"
      end

      def set_host_key_checking(enabled)
        @cmd_prefix << "ANSIBLE_HOST_KEY_CHECKING=#{enabled.to_s.capitalize}"
      end

      def ansible_execute_playbook(playbook_path, options = [])
        build_and_run("ansible-playbook #{playbook_path.shellescape} -l #{@node.name}", options)
      end

      def ansible_execute_module(module_name, module_arguments, options = [])
        build_and_run("ansible #{@node.name} -m #{module_name} -a #{module_arguments.shellescape}", options)
      end

      private

      def build_and_run(cmd, options = [])
        ssh_session = @node.remote_connection.session
        cmd = [
          (@cmd_prefix.join(' ') unless @cmd_prefix.empty?),
          cmd,
          @hostfile_option,
          "-u #{ssh_session.options[:user]}",
          "--private-key=#{ssh_session.options[:keys].shellescape}",
          "#{options.join(' ')}"
          ].compact.join(' ')
          run_command(cmd)
      end

      def create_temp_file(filename, content)
        Tempfile.new(filename).tap do |f|
          f.write(content)
          f.flush
        end
      end
    end
  end
end