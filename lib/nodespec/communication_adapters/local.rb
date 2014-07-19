require 'nodespec/backends'

module NodeSpec
  module CommunicationAdapters
    module Local
      def backend_proxy(os = nil)
        BackendProxy.const_get(backend(os)).new
      end

      def backend(os = nil)
        os == 'Windows' ? Backends::Cmd : Backends::Exec
      end
    end
  end
end
