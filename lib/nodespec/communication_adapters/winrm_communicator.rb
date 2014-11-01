require 'winrm'
require 'nodespec/verbose_output'
require 'nodespec/runtime_gem_loader'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class WinrmCommunicator
      include VerboseOutput
      DEFAULT_PORT = 5985
      DEFAULT_TRANSPORT = :plaintext
      DEFAULT_TRANSPORT_OPTIONS = {disable_sspi: true}

      attr_reader :session

      def initialize(host, options = {})
        @host = host
        opts = options.dup
        port = opts.delete('port') || DEFAULT_PORT
        @endpoint = "http://#{host}:#{port}/wsman"

        if opts.has_key?('transport')
          @transport = opts.delete('transport').to_sym
          @options = opts
        else
          @transport = DEFAULT_TRANSPORT
          @options = DEFAULT_TRANSPORT_OPTIONS.merge(opts)
        end
        @options = @options.inject({}) {|h,(k,v)| h[k.to_sym] = v; h}
      end

      def init_session(configuration)
        configuration.unbind_ssh_session

        @session = configuration.bind_winrm_session_for({host: @host, endpoint: @endpoint}) do
          RuntimeGemLoader.require_or_fail('winrm') do
            verbose_puts "\nConnecting to #{@endpoint}..."
            WinRM::WinRMWebService.new(@endpoint, @transport, @options)
          end
        end
      end

      def backend_proxy
        BackendProxy.create(:winrm, @session)
      end

      def backend
        :winrm
      end
    end
  end
end