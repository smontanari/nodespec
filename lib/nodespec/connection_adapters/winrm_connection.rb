require 'nodespec/verbose_output'

module NodeSpec
  module ConnectionAdapters
    class WinrmConnection
      include VerboseOutput
      attr_reader :session

      def initialize(endpoint, transport, options = {})
        @endpoint = endpoint
        @transport = transport
        @options = options
      end

      def bind_to(configuration)
        current_session = configuration.winrm
        if current_session.nil? || current_session.endpoint != @endpoint
          verbose_puts "\nConnecting to #{@endpoint}..."
          current_session = WinRM::WinRMWebService.new(@endpoint, @transport, @options)
          configuration.winrm = current_session
        end
        @session = current_session
      end
    end
  end
end