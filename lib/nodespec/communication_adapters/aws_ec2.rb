require 'nodespec/runtime_gem_loader'
require_relative 'ssh_communicator'
require_relative 'winrm_communicator'

module NodeSpec
  module CommunicationAdapters
    class AwsEc2
      GEMLOAD_ERROR = 'In order to use any aws adapter you must install the Amazon Web Service gem'
      def self.communicator_for(node_name, options = {})
        RuntimeGemLoader.require_or_fail('aws-sdk', GEMLOAD_ERROR) do
          instance_name = options['instance'] || node_name
          ec2_instance = AWS.ec2.instances[instance_name]

          raise "EC2 Instance #{instance_name} is not reachable" unless ec2_instance.exists? && ec2_instance.status == :running
          if options.has_key?('winrm')
            WinrmCommunicator.new(ec2_instance.public_ip_address, options['winrm'])
          else
            SshCommunicator.new(ec2_instance.public_ip_address, options['ssh'] || {})
          end
        end
      end
    end
  end
end