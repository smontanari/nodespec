require 'os'
require 'nodespec/verbose_output'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class NativeCommunicator
      include VerboseOutput

      def bind_to(configuration)
        configuration.unbind_ssh_session
        configuration.unbind_winrm_session
        verbose_puts "\nRunning on local host..."
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
