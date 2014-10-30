require_relative 'ssh_communicator'

module NodeSpec
  module CommunicationAdapters
    class Ssh
      def self.communicator_for(node_name, options = {})
        opts = options.dup
        host = opts.delete('host') || node_name
        SshCommunicator.new(host, opts)
      end
    end
  end
end
