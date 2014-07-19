require_relative 'winrm_communicator'

module NodeSpec
  module CommunicationAdapters
    class Winrm
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        hostname = opts.delete('host') || node_name
        @connection = WinrmCommunicator.new(hostname, opts)
      end
    end
  end
end
