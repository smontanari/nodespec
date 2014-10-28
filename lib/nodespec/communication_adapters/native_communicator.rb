require 'os'
require 'nodespec/verbose_output'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class NativeCommunicator
      include VerboseOutput

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

      def backend_proxy
        BackendProxy.create(backend)
      end

      def backend
        OS.windows? ? :cmd : :exec
      end
    end
  end
end
