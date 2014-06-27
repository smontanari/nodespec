require 'net/ssh'
require 'nodespec/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    class Ssh
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        opts['host'] = node_name unless opts.has_key? 'host'
        @connection = SshConnection.new(opts)
      end
    end
  end
end
