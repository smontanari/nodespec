require 'net/ssh'
require 'nodespec/verbose_output'
require 'nodespec/backend_proxy'

module NodeSpec
  module CommunicationAdapters
    class SshCommunicator
      include VerboseOutput
      attr_reader :session

      def initialize(host, options = {})
        @host = host
        @ssh_options = Net::SSH.configuration_for(@host)
        @user = options['user'] || @ssh_options[:user]
        %w[port password keys].each do |param|
          @ssh_options[param.to_sym] = options[param] if options[param]
        end
      end

      def bind_to(configuration)
        configuration.unbind_winrm_session

        @session = configuration.bind_ssh_session_for(@host, @ssh_options[:port]) do
          msg = "\nConnecting to #{@host}"
          msg << ":#{@ssh_options[:port]}" if @ssh_options[:port]
          msg << " as #{@user}..."
          verbose_puts msg
          Net::SSH.start(@host, @user, @ssh_options)
        end
      end

      def backend_proxy
        BackendProxy.create(:ssh, @session)
      end

      def backend
        :ssh
      end
    end
  end
end