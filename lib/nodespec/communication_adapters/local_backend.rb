require 'nodespec/backends'

module NodeSpec
  module CommunicationAdapters
    module LocalBackend
      def backend_proxy
        BackendProxy.const_get(backend).new
      end

      def backend
        os == 'Windows' ? Backends::Cmd : Backends::Exec
      end
    end
  end
end
