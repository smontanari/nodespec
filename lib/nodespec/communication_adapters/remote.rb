require 'nodespec/backends'

module NodeSpec
  module CommunicationAdapters
    module Remote
      def backend_proxy(os = nil)
        BackendProxy.const_get(backend(os)).new(session)
      end

      def backend(os = nil)
        os == 'Windows' ? Backends::WinRM : Backends::Ssh
      end
    end
  end
end
