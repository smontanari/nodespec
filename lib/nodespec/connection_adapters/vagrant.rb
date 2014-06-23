require 'open3'

module NodeSpec
  module Adapters
    class Vagrant
      attr_reader :connection
      
      def initialize(node_name, options = {})
        vm_name = options['vm_name'] || node_name
        fetch_connection_details(vm_name) do |*args|
          @connection = SshConnection.new(*args)
        end
      end

      private

      def fetch_connection_details(vm_name)
        cmd = "vagrant --machine-readable ssh-config #{vm_name}"
        output, status = Open3.capture2e(cmd)
        raise parse_error_data(output) unless status.success?
        yield(*parse_ssh_config_data(output)) if block_given?
      end

      def parse_ssh_config_data(data)
        /^\s*HostName\s+(?<hostname>.*)$/ =~ data
        /^\s*Port\s+(?<port>\d+)$/ =~ data
        /^\s*User\s+(?<username>.*)$/ =~ data
        /^\s*IdentityFile\s+(?<private_key_path>.*)$/ =~ data
        [hostname, username, {port: port.to_i, keys: private_key_path}]
      end

      def parse_error_data(data)
        /^.*,error-exit,(?<error>.*)$/ =~ data
        error
      end
    end
  end
end
