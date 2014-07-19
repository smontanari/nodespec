require 'net/ssh'
require_relative 'ssh_communicator'

module NodeSpec
  module CommunicationAdapters
    class Ssh
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        host = opts.delete('host') || node_name
        @connection = SshCommunicator.new(host, opts)
      end
    end
  end
end
