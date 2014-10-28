require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    module LocalBackend
      def backend_proxy
        BackendProxy.create(backend)
      end

      def backend
        os == 'Windows' ? :cmd : :exec
      end
    end
  end
end
