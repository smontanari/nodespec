require 'net/ssh'
require_relative 'ssh_connection'

module NodeSpec
  module ConnectionAdapters
    class Ssh
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        host = opts.delete('host') || node_name
        @connection = SshConnection.new(host, opts)
      end
    end
  end
end
