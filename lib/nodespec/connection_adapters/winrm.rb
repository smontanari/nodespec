require_relative 'winrm_connection'

module NodeSpec
  module ConnectionAdapters
    class Winrm
      DEFAULT_PORT = 5985
      DEFAULT_TRANSPORT = :plaintext
      DEFAULT_TRANSPORT_OPTIONS = {disable_sspi: true}
      attr_reader :connection

      def initialize(node_name, options = {})
        opts = options.dup
        hostname = opts.delete('host') || node_name
        port = opts.delete('port') || DEFAULT_PORT
        if opts.has_key?('transport')
          transport = opts.delete('transport')
          winrm_options = opts
        else
          transport = DEFAULT_TRANSPORT
          winrm_options = DEFAULT_TRANSPORT_OPTIONS.merge(opts)
        end
        endpoint = "http://#{hostname}:#{port}/wsman"
        
        @connection = WinrmConnection.new(endpoint, transport.to_sym, winrm_options)
      end
    end
  end
end
