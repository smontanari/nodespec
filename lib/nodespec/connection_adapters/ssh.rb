require 'net/ssh'
require 'nodespec/ssh_connection'

module NodeSpec
  module ConnectionAdapters
    class Ssh
      attr_reader :connection

      def initialize(node_name, options = {})
        options['host'] = node_name unless options.has_key? 'host'
        @connection = SshConnection.new(options)
      end
    end
  end
end
