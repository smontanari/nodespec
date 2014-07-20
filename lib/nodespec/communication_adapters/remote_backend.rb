require 'nodespec/backends'

module NodeSpec
  module CommunicationAdapters
    module RemoteBackend
      def backend_proxy
        BackendProxy.const_get(backend).new(session)
      end

      def backend
        os == 'Windows' ? Backends::WinRM : Backends::Ssh
      end
    end
  end
end
