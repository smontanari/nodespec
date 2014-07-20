require 'open3'
require_relative 'ssh_communicator'

module NodeSpec
  module CommunicationAdapters
    class Vagrant
      def self.communicator_for(node_name, os = nil, options = {})
        vm_name = options['vm_name'] || node_name
        fetch_connection_details(vm_name) do |host, opts|
          SshCommunicator.new(host, os, opts)
        end
      end

      private

      def self.fetch_connection_details(vm_name)
        cmd = "vagrant --machine-readable ssh-config #{vm_name}"
        output, status = Open3.capture2e(cmd)
        raise parse_error_data(output) unless status.success?
        yield(parse_ssh_config_data(output)) if block_given?
      end

      def self.parse_ssh_config_data(data)
        /^\s*HostName\s+(?<hostname>.*)$/ =~ data
        /^\s*Port\s+(?<port>\d+)$/ =~ data
        /^\s*User\s+(?<username>.*)$/ =~ data
        /^\s*IdentityFile\s+(?<private_key_path>.*)$/ =~ data
        [hostname, {'port' => port.to_i, 'user' => username, 'keys' => private_key_path}]
      end

      def self.parse_error_data(data)
        /^.*,error-exit,(?<error>.*)$/ =~ data
        error
      end
    end
  end
end
