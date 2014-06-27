require 'aws-sdk'
require 'nodespec/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    class AmazonEc2
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        instance_name = opts.delete('instance') || node_name
        ec2_instance = AWS.ec2.instances[instance_name]

        raise "Instance #{instance_name} is not reachable" unless ec2_instance.exists? && ec2_instance.status == :running

        opts['host'] = ec2_instance.public_ip_address
        @connection = SshConnection.new(opts)
      end
    end
  end
end