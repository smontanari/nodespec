require_relative 'winrm_communicator'

module NodeSpec
  module CommunicationAdapters
    class Winrm
      def self.communicator_for(node_name, os = nil, options = {})
        opts = options.dup
        hostname = opts.delete('host') || node_name
        WinrmCommunicator.new(hostname, os, opts)
      end
    end
  end
end
