require 'nodespec/runtime_gem_loader'
require_relative 'ssh_connection'
require_relative 'winrm_connection'

module NodeSpec
  module ConnectionAdapters
    module AwsEc2
      GEMLOAD_ERROR = 'In order to use any aws adapter you must install the Amazon Web Service gem'
      def self.new(node_name, options)
        RuntimeGemLoader.require_or_fail('aws-sdk', GEMLOAD_ERROR) do
          AwsEc2.new(node_name, options)
        end
      end

      class AwsEc2
        attr_reader :connection

        def initialize(node_name, options = {})
          instance_name = options['instance'] || node_name
          ec2_instance = AWS.ec2.instances[instance_name]

          raise "EC2 Instance #{instance_name} is not reachable" unless ec2_instance.exists? && ec2_instance.status == :running
          if options.has_key?('winrm')
            @connection = WinrmConnection.new(ec2_instance.public_dns_name, options['winrm'])
          else
            @connection = SshConnection.new(ec2_instance.public_dns_name, options['ssh'] || {})
          end
        end
      end
    end
  end
end