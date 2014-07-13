require_relative 'winrm_connection'

module NodeSpec
  module ConnectionAdapters
    class Winrm
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        hostname = opts.delete('host') || node_name
        @connection = WinrmConnection.new(hostname, opts)
      end
    end
  end
end
