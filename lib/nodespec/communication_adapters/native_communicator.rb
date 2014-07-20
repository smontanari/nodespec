require 'nodespec/verbose_output'
require_relative 'local_backend'

module NodeSpec
  module CommunicationAdapters
    class NativeCommunicator
      include LocalBackend
      include VerboseOutput

      attr_reader :os

      def initialize(os = nil)
        @os = os
      end

      def bind_to(configuration)
        if configuration.ssh
          msg = "\nClosing connection to #{configuration.ssh.host}"
          msg << ":#{configuration.ssh.options[:port]}" if configuration.ssh.options[:port]
          verbose_puts msg
          configuration.ssh.close
          configuration.ssh = nil
          verbose_puts "\nRunning on local host..."
        end

        if configuration.winrm
          configuration.winrm = nil
        end
      end
    end
  end
end
