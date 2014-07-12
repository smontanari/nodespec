require 'nodespec/runtime_gem_loader'
require_relative 'ssh_connection'

module NodeSpec
  module ConnectionAdapters
    module AmazonEc2
      GEMLOAD_ERROR = 'In order to use the amazon_ec2 adapter you must install the Amazon Web Service gem'
      def self.new(node_name, options)
        RuntimeGemLoader.require_or_fail('aws-sdk', GEMLOAD_ERROR) do
          AmazonEc2.new(node_name, options)
        end
      end

      class AmazonEc2
        attr_reader :connection

        def initialize(node_name, options = {})
          opts = options.dup
          instance_name = opts.delete('instance') || node_name
          ec2_instance = AWS.ec2.instances[instance_name]

          raise "EC2 Instance #{instance_name} is not reachable" unless ec2_instance.exists? && ec2_instance.status == :running

          opts['host'] = ec2_instance.public_dns_name
          @connection = SshConnection.new(opts)
        end
      end
    end
  end
end