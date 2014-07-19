require 'nodespec/verbose_output'
require_relative 'local'

module NodeSpec
  module CommunicationAdapters
    class NativeCommunicator
      include Local
      include VerboseOutput

      def bind_to(configuration)
        if configuration.ssh
          msg = "\nClosing connection to #{configuration.ssh.host}"
          msg << ":#{configuration.ssh.options[:port]}" if configuration.ssh.options[:port]
          verbose_puts msg
          configuration.ssh.close
          configuration.ssh = nil
        end

        if configuration.winrm
          configuration.winrm = nil
        end
      end
    end
  end
end
