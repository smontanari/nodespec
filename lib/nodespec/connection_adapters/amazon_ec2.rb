require 'nodespec/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    module AmazonEc2
      def self.new(node_name, options)
        begin
          require 'aws-sdk'
          AmazonEc2.new(node_name, options)
        rescue LoadError => e
          puts <<-EOS
Error: #{e.message}
In order to use the amazon_ec2 adapter you must install the Amazon Web Service gem:

gem install 'aws-sdk'
EOS
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