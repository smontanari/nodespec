require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    module RemoteBackend
      def backend_proxy
        BackendProxy.create(backend, session)
      end

      def backend
        os == 'Windows' ? :winrm : :ssh
      end
    end
  end
end
